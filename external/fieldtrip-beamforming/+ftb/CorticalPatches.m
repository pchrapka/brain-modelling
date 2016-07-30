classdef CorticalPatches < ftb.AnalysisStep
    
    properties(SetAccess = private)
        config;
        patches;
    end
    
    methods
        function obj = CorticalPatches(params,name)
            %   params (struct or string)
            %       struct or file name
            %       including mri_data
            %   name(string)
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
            % set vars
            obj@ftb.AnalysisStep('CP');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            % set previous step, aka none
            obj.prev = [];
            
            obj.patches = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.EEG'));
            parse(p,prev);
            
            % set the previous step, aka EEG
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
            [obj.sourceanalysis] = obj.init_output(analysis_folder,...
                'properties',{'patches'});
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % get analysis step objects
            lfObj = obj.get_dep('ftb.Leadfield');
            
            if obj.check_file(obj.patches)
                % load data
                leadfield = ftb.util.loadvar(lfObj.leadfield);
                patches_list = obj.get_patches(obj.config.name);
                % FIXME this shouldn't be so specific
                
                % get the patch basis
                if ~isfield(obj.config,'ftb_patches_basis')
                    obj.config.ftb_patches_basis = {};
                end
                patches_list = obj.get_basis(patches_list, leadfield,...
                    obj.config.ftb_patches_basis{:});
                
                % save patches
                save(obj.patches, 'patches_list');
            else
                fprintf('%s: skipping ftb.patches.basis, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
        
        function plot(obj,elements)
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
        
    end
    
    methods(Access = protected)
        patches = get_basis(patches, leadfield, varargin);
        
        function patches = get_patches(config_name)
            switch config_name
                case 'aal-coarse-13'
                    patches = get_aal_coarse();
                case 'aal'
                    patches = get_all();
                otherwise
                    error('unknown cortical patch config: %s\n',config_name);
            end     
        end
    end
    
end