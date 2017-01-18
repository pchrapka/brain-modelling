classdef EEG < ftb.AnalysisStep
    %EEG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = protected)
        config;
        definetrial;
        redefinetrial;
        preprocessed;
        timelock;
        rejectartifact;
    end
    
    methods(Access = private)
        obj = process_default(obj);
        %obj = process_subtract(obj);
        obj = process_artifact(obj);
        obj = process_timelock(obj);
        obj = process_preprocessing(obj,varargin);
        obj = process_definetrial(obj);
        obj = process_redefinetrial(obj);
    end
    
    methods
        function obj = EEG(params,name)
            %   params (struct or string)
            %       struct or file name
            %   name (string)
            %       object name
            
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
                din = ftb.util.loadvar(p.Results.params);
                obj.config = din;
            end
            
            obj.definetrial = '';
            obj.redefinetrial = '';
            obj.preprocessed = '';
            obj.timelock = '';
            obj.rejectartifact = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',...
                @(x)isa(x,'ftb.Leadfield') || isa(x,'ftb.EEG') || isa(x,'ftb.Beamformer'));
            parse(p,prev);
            
            % set the previous step
            obj.prev = p.Results.prev;
        end
        
        function obj = init(obj,analysis_folder)
            %INIT initializes the output files
            %   INIT(analysis_folder)
            %
            %   Input
            %   -----
            %   analysis_folder (string)
            %       root folder for the analysis output
            
            % init output folder and files
            properties = {'definetrial','redefinetrial','preprocessed','timelock','rejectartifact'};
            for i=1:length(properties)
                obj.(properties{i}) = obj.init_output(analysis_folder,...
                    'properties',properties{i});
            end
            
            % set the init flag
            obj.init_called = true;
            
            % load any files specified in the config
            obj.load_files();
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
        
        function plot_data(obj,mode,varargin)
            %   mode (string)
            %       selects data to plot: 'preprocessed' or 'timelock'
            
            if nargin > 2
                cfgin = varargin{1};
            else
                cfgin = [];
            end
            
            switch mode
                case 'timelock'
                    
                    eObj = obj.get_dep('ftb.Electrodes');
                    cfg.elecfile = eObj.elec_aligned;
                    layout = ft_prepare_layout(cfg,[]);
                    
                    %cfgin.hlim = [0 1];
                    cfgin.layout = layout;
                    cfgin.showlabels = 'yes';
                    ft_multiplotER(cfgin, ftb.util.loadvar(obj.timelock));
                    
                case {'preprocessed','rejectartifact'}
                    
                    ft_databrowser(cfgin,ftb.util.loadvar(obj.(mode)));
                    
                otherwise
                    error(['ftb:' mfilename],...
                        'unknown mode %s',mode);
            end
        end
        
        function print_labels(obj)
            %PRINT_LABELS prints EEG and sensor labels
            %   PRINT_LABELS prints EEG and sensor labels
            %   Fieldtrip has bugs when the labels aren't the same order, i
            %   think
            
            elecObj = obj.get_dep('ftb.Electrodes');
            lfObj = obj.get_dep('ftb.Leadfield');
            elec = ftb.util.loadvar(elecObj.elec_aligned);
            lf = ftb.util.loadvar(lfObj.leadfield);
            eeg = ftb.util.loadvar(obj.preprocessed);
            
            nlabels = max([length(eeg.label), length(elec.label), length(lf.label)]);
            for i=1:nlabels
                if i > length(eeg.label)
                    fprintf('eeg: NA ');
                else
                    fprintf('eeg: %s ', eeg.label{i});
                end
                
                if i > length(elec.label)
                    fprintf('\tsens: NA ');
                else
                    fprintf('\tsens: %s ', elec.label{i});
                end
                
                if i > length(lf.label)
                    fprintf('\tlf: NA ');
                else
                    fprintf('\tlf: %s ', lf.label{i});
                end
                    
                fprintf('\n');
            end
            
        end
        
    end
end

