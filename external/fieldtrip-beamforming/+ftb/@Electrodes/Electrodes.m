classdef Electrodes < ftb.AnalysisStep
    %Electrodes Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        config;
        elec;
        elec_aligned;
        
        process_mode;
    end
    
    methods(Access = private)
        obj = process_default(obj)
        obj = process_auto(obj)
    end
    
    methods
        function obj = Electrodes(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Headmodel Object)
            %       previous analysis step - Headmodel Object
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
            % set vars
            obj@ftb.AnalysisStep('E');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            obj.elec = '';
            obj.elec_aligned = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Headmodel'));
            parse(p,prev);
            
            % set the previous step, aka Headmodel
            obj.prev = p.Results.prev;
        end
        
        function obj = init(obj,out_folder)
            
            % parse inputs
            p = inputParser;
            addOptional(p,'out_folder','',@ischar);
            parse(p,out_folder);
            
            % check inputs
            if isempty(out_folder)
                error(['ftb:' mfilename],...
                    'please specify an output folder');
            end
            
            % create folder for analysis step, name accounts for dependencies
            out_folder2 = fullfile(out_folder, obj.get_name());
            if ~exist(out_folder2,'dir')
                mkdir(out_folder2)
            end
            
            % Set up file names
            obj.elec = fullfile(out_folder2, 'elec.mat');
            obj.elec_aligned = fullfile(out_folder2, 'elec_aligned.mat');
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            debug = false;
            
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % Check if we're setting up a head model from scratch
            if ~obj.check_file(obj.elec_aligned)
                % Return if it already exists
                fprintf('%s: skipping %s, already exists\n', mfilename, obj.elec_aligned);
                return
            end
            
            % Load electrode data
            if obj.check_file(obj.elec)
                data = ft_read_sens(obj.config.elec_orig);
                % Ensure electrode coordinates are in mm
                data = ft_convert_units(data, 'mm'); % should be the same unit as MRI
                % Save
                save(obj.elec, 'data');
            else
                fprintf('%s: skipping ft_read_sens, already exists\n',mfilename);
            end
            
            if debug
                % plot pre-alignment
                elements = {'electrodes', 'scalp'};
                obj.plot(elements);
            end
            
            % determine process mode
            if ~isfield(obj.config, 'ft_electroderealign')
                obj.process_mode = 'auto';
            else
                obj.process_mode = 'default';
            end
            
            switch obj.process_mode
                case 'auto'
                    obj.process_auto();
                case 'default'
                    obj.process_default();
                otherwise
                    error(['ftb:' mfilename], 'unknown mode %s', obj.process_mode)
            end
        end
        
        function align_electrodes(obj, type, varargin)
            % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
            
            % parse inputs
            p = inputParser;
            addRequired(p,'type',@ischar);
            addParameter(p,'Input',obj.elec,@ischar);
            addParameter(p,'Output',obj.elec_aligned,@ischar);
            parse(p,type,varargin{:});
            type = p.Results.type;
            in_file = p.Results.Input;
            out_file = p.Results.Output;
            
            % Load electrodes
            elec = ftb.util.loadvar(in_file);
            % load head model obj
            hmObj = obj.prev;
            % load mri obj
            mriObj = hmObj.prev;
            
            switch type
                
                case 'fiducial'
                    % Fiducial alignment
                    
                    [pos,names] = mriObj.get_mri_fiducials();
                    
                    % create a structure similar to a template set of electrodes
                    fid.chanpos       = pos;       % ctf-coordinates of fiducials
                    fid.label         = {'FidNz','FidT9','FidT10'};    % same labels as in elec
                    fid.unit          = 'mm';                  % same units as mri
                    
                    % Alignment
                    cfgin               = [];
                    cfgin.method        = 'fiducial';
                    cfgin.template      = fid;                   % see above
                    % NOTE If you want to address the warning RE
                    % cfgin.template, you need to use chanpos
                    %cfgin.target.chanpos(1,:) = nas;
                    %cfgin.target.chanpos(2,:) = lpa;
                    %cfgin.target.chanpos(3,:) = rpa;
                    %cfgin.target.label    = {'FidNz','FidT9','FidT10'};
                    cfgin.elec          = elec;
                    cfgin.fiducial      = {'FidNz','FidT9','FidT10'};  % labels of fiducials in fid and in elec
                    elec      = ft_electroderealign(cfgin);
                    
                    % Remove the fiducial labels
                    %         temp = ft_channelselection({'all','-FidNz','-FidT9','-FidT10'}, elec.label);
                    
                case 'interactive'
                    % Interactive alignment
                    
                    vol = ftb.util.loadvar(hmObj.mri_headmodel);
                    
                    cfgin           = [];
                    cfgin.method    = 'interactive';
                    cfgin.elec      = elec;
                    if isfield(vol, 'skin_surface')
                        cfgin.headshape = vol.bnd(vol.skin_surface);
                    else
                        cfgin.headshape = vol.bnd(1);
                    end
                    elec  = ft_electroderealign(cfgin);
                    
                otherwise
                    error(['ftb:' mfilename],...
                        'unknown type %s', cfg.type);
                    
            end
            
            % Save
            save(out_file, 'elec');
            
        end
        
        function channels = remove_fiducials(obj)
            % removes fiducial channels
            % returns list of channels without fiducials
            
            % load electrodes
            sens = ftb.util.loadvar(obj.elec_aligned);
            % remove Fid channels
            channels = ft_channelselection({'all','-Fid*'}, sens.label);
            
        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'electrodes'
            %       'electrodes-aligned'
            %       'electrodes-labels'
            %
            %       can also include elements from previous stages
            %       'scalp'
            %       'skull'
            %       'brain'
            %       'fiducials'
            
            unit = 'mm';
            
            % check if we should plot labels
            plot_labels = any(cellfun(@(x) isequal(x,'electrodes-labels'),elements));
            
            for i=1:length(elements)
                switch elements{i}
                    
                    case 'electrodes'
                        hold on;
                        
                        % Load data
                        sens = ftb.util.loadvar(obj.elec);
                        
                        % Convert to mm
                        sens = ft_convert_units(sens, unit);
                        
                        % Plot electrodes
                        if plot_labels
                            ft_plot_sens(sens,'style','og','label','label');
                        else
                            ft_plot_sens(sens,'style','og');
                        end
                    
                    case 'electrodes-aligned'
                        hold on;
                        
                        % Load data
                        sens = ftb.util.loadvar(obj.elec_aligned);
                        
                        % Convert to mm
                        sens = ft_convert_units(sens, unit);
                        
                        % Plot electrodes
                        if plot_labels
                            ft_plot_sens(sens,'style','og','label','label');
                        else
                            ft_plot_sens(sens,'style','og');
                        end
                end
            end
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
    end
    
end

