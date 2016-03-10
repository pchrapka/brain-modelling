classdef Beamformer < ftb.AnalysisStep
    %Beamformer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = protected)
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
            eegObj = obj.get_dep('ftb.EEG');
            lfObj = obj.get_dep('ftb.Leadfield');
            elecObj = obj.get_dep('ftb.Electrodes');
            hmObj = obj.get_dep('ftb.Headmodel');
            
            % process source analysis
            obj.process_deps(eegObj,lfObj,elecObj,hmObj);
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
        
        function obj = remove_outlier(obj, n)
            %REMOVE_OUTLIER zeroes n sources with most power
            
            source = ftb.util.loadvar(obj.sourceanalysis);
            pow = source.avg.pow;
            % create an index
            idx = 1:length(pow);
            temp = [pow(:) idx(:)];
            % sort by source power
            sorted = sortrows(temp,-1);
            sorted(isnan(sorted(:,1)),:) = [];
            
            fprintf('found %d: %f\n', fliplr(sorted(1:n,:))');
            
            % get indices of top n sources
            idx_zero = sorted(1:n,2);
            % zero the top most
            pow(idx_zero) = NaN;
            
            % save data
            source.avg.pow = pow;
            save(obj.sourceanalysis,'source');
            
        end
        
        plot_anatomical(obj,varargin);
        plot_scatter(obj,cfg);
        plot_moment(obj,varargin);
    end
    
    methods(Access = protected)
        function obj = process_deps(obj,eegObj,lfObj,elecObj,hmObj)
            
            if obj.check_file(obj.sourceanalysis)
                % setup cfg
                cfgin = obj.config.ft_sourceanalysis;
                cfgin.elecfile = elecObj.elec_aligned;
                cfgin.headmodel = hmObj.mri_headmodel;
                cfgin.grid = ftb.util.loadvar(lfObj.leadfield);
                if isfield(obj.config.ft_sourceanalysis,'grid')
                    % there may some extra fields in grid from the original
                    % config, so copy them over
                    cfgin.grid = copyfields(obj.config.ft_sourceanalysis.grid, cfgin.grid,...
                        fieldnames(obj.config.ft_sourceanalysis.grid));
                end
                
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
    end
end

