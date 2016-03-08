classdef Beamformer < ftb.AnalysisStep
    %Beamformer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        config;
        sourceanalysis;
    end
    
    methods
        function obj = Beamformer(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
            % set vars
            obj@ftb.AnalysisStep('BF');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            obj.sourceanalysis = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.DipoleSim') || isa(x,'ftb.EEG'));
            parse(p,prev);
            
            % set the previous step, aka DipoleSim
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
            
            % set up file names
            obj.sourceanalysis = fullfile(out_folder2, 'sourceanalysis.mat');
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % get analysis step objects
            eegObj = obj.prev;
            lfObj = eegObj.prev;
            elecObj = lfObj.prev;
            hmObj = elecObj.prev;
            
            if obj.check_file(obj.sourceanalysis)
                % setup cfg
                cfgin = obj.config.ft_sourceanalysis;
                cfgin.elecfile = elecObj.elec_aligned;
                cfgin.headmodel = hmObj.mri_headmodel;
                cfgin.grid = ftb.util.loadvar(lfObj.leadfield);
                
                cfgin.inputfile = eegObj.timelock;
                cfgin.outputfile = obj.sourceanalysis;
                
                if ~isfield(cfgin, 'channel')
                    % Remove fiducial channels
                    elec = ftb.util.loadvar(cfgin.elecfile);
                    cfgin.channel = ft_channelselection(...
                        {'all', ['-' elecObj.fid_nas], ['-' elecObj.fid_lpa],...
                        ['-' elecObj.fid_rpa]}, elec.label);
                end
                
                % source analysis
                ft_sourceanalysis(cfgin)
            else
                fprintf('%s: skipping ft_sourceanalysis, already exists\n',...
                    mfilename);
            end
        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted from
            %       previous stages
            %       'dipole'
            %       'leadfield'
            %       'electrodes'
            %       'electrodes-aligned'
            %       'electrodes-labels'
            %       'scalp'
            %       'skull'
            %       'brain'
            %       'fiducials'
            
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
        
        plot_anatomical(obj);
        plot_scatter(obj,cfg);
    end
end

