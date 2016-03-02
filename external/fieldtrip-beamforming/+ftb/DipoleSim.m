classdef DipoleSim < ftb.AnalysisStep
    %DipoleSim Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        config;
        simulated;
        timelock;
    end
    
    methods
        function obj = DipoleSim(params,name)
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
            obj@ftb.AnalysisStep('DS');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            obj.simulated = '';
            obj.timelock = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Leadfield'));
            parse(p,prev);
            
            % set the previous step, aka Leadfield
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
            obj.simulated = fullfile(out_folder2, 'simulated.mat');
            obj.timelock = fullfile(out_folder2, 'timelock.mat');
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % get analysis step objects
            lfObj = obj.prev;
            elecObj = lfObj.prev;
            hmObj = elecObj.prev;
            
            if obj.check_file(obj.simulated)
                % setup cfg
                cfgin = obj.config.ft_dipolesimulation;
                cfgin.elecfile = elecObj.elec_aligned;
                cfgin.headmodel = hmObj.mri_headmodel;
                
                % remove fiducial channels
                if ~isfield(cfgin, 'channel')
                    cfgin.channel = elecObj.remove_fiducials();
                    fprintf('%s: removing fiducial electrodes\n', mfilename)
                end
                
                % simulate dipoles
                data = ft_dipolesimulation(cfgin);
                save(obj.simulated, 'data');
            else
                fprintf('%s: skipping ft_dipolesimulation, already exists\n',...
                    mfilename);
            end
            
            if obj.check_file(obj.timelock)
                cfgin = obj.config.ft_timelockanalysis;
                cfgin.inputfile = obj.simulated;
                cfgin.outputfile = obj.timelock;
                
                ft_timelockanalysis(cfgin);
            else
                fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
                    mfilename);
            end
            

        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'dipole'
            %       can also include elements from previous stages
            %       'leadfield'
            %       'electrodes'
            %       'electrodes-aligned'
            %       'electrodes-labels'
            %       'scalp'
            %       'skull'
            %       'brain'
            %       'fiducials'
            
            unit = 'mm';
            
            for i=1:length(elements)
                switch elements{i}
                    
                    case 'dipole'
                        hold on;
                        
                        component = 'signal';
                        
                        switch component
                            case 'signal'
                                color = 'blue';
                            case 'interference'
                                color = 'red';
                            otherwise
                        end
                        
                        params = obj.config.ft_dipolesimulation;
                        if isfield(params, 'dip')
                            dip = params.dip;
                            if ~isequal(dip.unit, unit)
                                switch dip.unit
                                    case 'cm'
                                        dip.pos = dip.pos*10;
                                    otherwise
                                        error(['ftb:' mfilename],...
                                            'implement unit %s', dip.unit);
                                end
                            end
                            ft_plot_dipole(dip.pos, dip.mom,...
                                ...'diameter',5,...
                                ...'length', 10,...
                                'color', color,...
                                'unit', unit);
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

