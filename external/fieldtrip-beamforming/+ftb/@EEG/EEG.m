classdef EEG < ftb.AnalysisStep
    %EEG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        config;
        definetrial;
        preprocessed;
        timelock;
    end
    
    methods(Access = private)
        obj = process_default(obj);
        %obj = process_subtract(obj);
    end
    
    methods
        function obj = EEG(params,name)
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
            obj@ftb.AnalysisStep('EEG');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            obj.definetrial = '';
            obj.preprocessed = '';
            obj.timelock = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',...
                @(x)isa(x,'ftb.Leadfield') || isa(x,'ftb.EEG') || isa(x,'ftb.Beamformer'));
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
            obj.definetrial = fullfile(out_folder2, 'definetrial.mat');
            obj.preprocessed = fullfile(out_folder2, 'preprocessed.mat');
            obj.timelock = fullfile(out_folder2, 'timelock.mat');
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            obj = obj.process_default();

        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       can also include elements from previous stages
            %       'dipole'
            %       'leadfield'
            %       'electrodes'
            %       'electrodes-aligned'
            %       'electrodes-labels'
            %       'scalp'
            %       'skull'
            %       'brain'
            %       'fiducials'
            
            unit = 'mm';
            
%             for i=1:length(elements)
%                 switch elements{i}
%                     
%                     case 'dipole'

%                 end
%             end
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
        
        function plot_data(obj,mode)
            %   mode (string)
            %       selects data to plot: 'preprocessed'
            
            switch mode
                case 'timelock'
                    eObj = obj.get_dep('ftb.Electrodes');
                    cfg.elecfile = eObj.elec_aligned;
                    layout = ft_prepare_layout(cfg,[]);
                    
                    data = ftb.util.loadvar(obj.timelock);
                    cfg = [];
                    %cfg.hlim = [0 1];
                    cfg.layout = layout;
                    cfg.showlabels = 'yes';
                    ft_multiplotER(cfg, data);
                    
                case 'preprocessed'
                    
                    ft_databrowser([],ftb.util.loadvar(obj.preprocessed));
                otherwise
                    error(['ftb:' mfilename],...
                        'unknown mode %s',mode);
            end
        end
        
    end
end

