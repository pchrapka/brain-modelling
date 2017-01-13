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
        
        function obj = init(obj,analysis_folder)
            %INIT initializes the output files
            %   INIT(analysis_folder)
            %
            %   Input
            %   -----
            %   analysis_folder (string)
            %       root folder for the analysis output
            
            % init output folder and files
            obj.init_output(analysis_folder,...
                'properties',{'sourceanalysis'});
            
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
                
                % NOTE for some reason, at some point before this stage
                % the channel labels have no hyphens
                %if ~isfield(cfgin, 'channel')
                %    % Remove fiducial channels
                %    cfgin.channel = elecObj.remove_fiducials();
                %end
                
                % source analysis
                ft_sourceanalysis(cfgin)
            else
                fprintf('%s: skipping ft_sourceanalysis, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
        
        function plot_anatomical_deps(~,mri,source,varargin)
            %PLOT_ANATOMICAL_DEPS plots source power on anatomical image
            %   PLOT_ANATOMICAL_DEPS(obj, ['method', value, 'options', value]) plots source
            %   power on anatomical images. Method can be 'slice' or 'ortho'.
            %
            %   Input
            %   -----
            %   mri (struct)
            %       mri data, ftb.MRI.mri_mat
            %   source (struct)
            %       source analysis data, ftb.Beamformer.sourceanalysis
            %
            %   Parameters
            %   ----------
            %   method (default = 'slice')
            %       plotting method: slice or ortho
            %   options (struct)
            %       options for ft_sourceplot, see ft_sourceplot
            %   mask (default = 'none')
            %       mask for functional data, if using this opt
            %       thresh - plots values above a threshold
            %       none - no mask
            %   thresh (default = 0.5)
            %       threshold for mask = 'thresh', calculated as a factor
            %       of the maximum power
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addParameter(p,'method','slice',@(x)any(validatestring(x,{'slice','ortho'})));
            addParameter(p,'options',[]);
            addParameter(p,'mask','none',@(x)any(validatestring(x,{'thresh','none'})));
            addParameter(p,'thresh',0.5,@isnumeric);
            parse(p,varargin{:});
            
            % reslice
            % TODO save instead of redoing
            cfgin = [];
            resliced = ft_volumereslice(cfgin, mri);
            
            if isfield(source,'time')
                source = rmfield(source,'time');
            end
            
            % interpolate
            cfgin = [];
            cfgin.parameter = 'pow';
            interp = ft_sourceinterpolate(cfgin, source, resliced);
            
            % data transformation
            plot_log = false;
            if plot_log
                interp.pow = db(interp.pow,'power');
            end
            
            % source plot
            cfgplot = [];
            if ~isempty(p.Results.options)
                % copy options
                cfgplot = copyfields(p.Results.options, cfgplot, fieldnames(p.Results.options));
            end
            
            if isfield(cfgplot,'mask') && ~isempty(p.Results.mask)
                warning('overwriting mask field');
            end
            switch p.Results.mask
                case 'thresh'
                    fprintf('creating mask\n');
                    cfgplot.maskparameter = 'mask';
                    interp.mask = interp.pow > max(interp.pow(:))*p.Results.thresh;
                case 'none'
                    % none
            end
            
            cfgplot.method = p.Results.method;
            cfgplot.funparameter = 'pow';
            ft_sourceplot(cfgplot, interp);
        end
    end
end

