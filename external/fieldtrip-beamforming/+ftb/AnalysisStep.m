classdef AnalysisStep < handle
    %AnalysisStep Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = protected)
        prefix;
        name;
        
        % state
        init_called;
        
        % linked prev object
        prev;
        
        folder;
    end
    
    properties
        force;
    end
    
    methods
        function obj = AnalysisStep(varargin)
            
            p = inputParser;
            addOptional(p,'prefix','',@ischar);
            parse(p,varargin{:});
            
            obj.prefix = p.Results.prefix;
            obj.name = '';
            obj.prev = [];
            obj.folder = '';
            obj.init_called = false;
            obj.force = false;
        end
        
        function name = get_name(obj)
            %GET_NAME returns name of analysis step based on dependency
            %structure
            %   GET_NAME returns name of analysis step based on dependency
            %   structure
            %   
            %   Output
            %   ------
            %   name (string)
            %       name of analysis step with dependency names prefixed to
            %       it
            
            % create current object name
            name = [obj.prefix obj.name];
            
            % prefix with name of previous step
            if ~isempty(obj.prev)
                prev_name = obj.prev.get_name();
                name = [prev_name '-' name];
            end
        end
        
        function restart = check_deps(obj)
            %CHECK_DEPS checks if any dependencies have been recomputed
            %   CHECK_DEPS checks if any dependencies have been recomputed
            %   
            %   Output
            %   ------
            %   restart (boolean)
            %       true if any previous step has its restart flag set to
            %       true, false otherwise
            
            restart = false;
            ptr = obj.prev;
            while ~isempty(ptr)
                if ptr.force
                    restart = true;
                    break;
                end
                ptr = ptr.prev;
            end
            
        end
        
        function result = get_dep(obj,class_name,varargin)
            %GET_DEP finds dependencies that match the class name
            %   GET_DEP(obj, class_name, [mode]) finds dependencies that
            %   match the class name, mode = 'first' by default
            %
            %   GET_DEP(obj, class_name, 'first') finds first dependency
            %   that matches the class name
            %
            %   GET_DEP(obj, class_name, 'all') finds all dependencies that
            %   match the class name
            %
            %   Input
            %   -----
            %   class_name (string)
            %       name of class, ex. ftb.MRI
            %
            %   Parameters
            %   ----------
            %   mode (optional, default = 'first')
            %       selects number of results to find
            %   
            %   Output
            %   ------
            %   result (Object)
            %       mode = 'first'
            %       first dependency that matches the class name
            %       mode = 'all'
            %       array of depedencies that match the class name
            %       otherwise {}
            
                        
            p = inputParser;
            addOptional(p,'mode','first',...
                @(x)any(validatestring(x,{'first','all'})));
            parse(p,varargin{:});
            
            result = {};
            ptr = obj.prev;
            while ~isempty(ptr)
                % check if class matches
                if isa(ptr,class_name)
                    if isequal(p.Results.mode,'first')
                        result = ptr;
                        break;
                    elseif isequal(p.Results.mode,'all')
                        result{end+1} = ptr;
                    end
                end
                ptr = ptr.prev;
            end
        end
        
        function load_file(obj, property, filename)
            %LOAD_FILE loads a  precomputed output file
            %   LOAD_FILE loads a precomputed output file
            %   
            %   Input
            %   -----
            %   property (string)
            %       object property
            %   filename (string)
            %       precomputed data in mat file
            
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % check property
            if ~isprop(obj, property)
                error(['ftb:' mfilename],...
                    'not a property %s', property);
            end
            
            % check file
            [~,~,ext] = fileparts(filename);
            if ~isequal(ext,'.mat')
                error(['ftb:' mfilename],...
                    'not sure what to do with %s file', ext);
            end
            
            if obj.check_file(obj.(property))
                fprintf('%s: loading %s\n', strrep(class(obj),'ftb.',''), filename);
                
                % load data
                data = ftb.util.loadvar(filename);
                save(obj.(property),'data');
            else
                fprintf('%s: skipping load_file, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
        
    end
    
    methods (Access = protected)
        function restart = check_file(obj, file)
            %CHECK_FILE check if file needs to recomputed
            %   CHECK_FILE check if file needs to recomputed. Based on
            %   force property in current object (obj.force) and previous
            %   objects (obj.prev.force,...) and existence of file
            %
            %   Output
            %   ------
            %   restart (boolean)
            %       true if the file needs to be recomputed, false otherwise
            
            force_deps = obj.check_deps();
            restart = ~exist(file, 'file') || obj.force || force_deps;
        end
        
        function load_files(obj)
            %LOAD_FILES loads files specified in the config
            %
            %   Requires load_files field in params struct or file. The
            %   field should be formatted as a listed of property and file
            %   name pairs'
            %   For example:
            %       cfg.load_files = {...
            %           {'mri_mat', 'standard_mri.mat'},...
            %           {'mri_segmented', 'standard_seg.mat'}};
            %
            
            if ~isfield(obj.config,'load_files')
                return;
            end
            
            for i=1:length(obj.config.load_files)
                property = obj.config.load_files{i}{1};
                file_name = obj.config.load_files{i}{2};
                obj.load_file(property,file_name);
            end
        end
        
        function [varargout] = init_output(obj,analysis_folder,varargin)
            %INIT_OUTPUT initializes the output for the step
            %   INIT_OUTPUT(analysis_folder ,['properties', {}])
            %
            %   Input
            %   -----
            %   analysis_folder (string)
            %       root folder for the analysis output
            %   
            %   Parameters
            %   ----------
            %   properties (cell array)
            %       cell array of class specific properties for which
            %       output files are required
            %
            %   Output
            %   ------
            %   property_file (vararout)
            %       output path and file for each property
            
            % parse inputs
            p = inputParser;
            addRequired(p,'analysis_folder',@(x) ~isempty(x) && ischar(x));
            addParameter(p,'properties',{},@iscell);
            parse(p,analysis_folder,varargin{:});
            
            % create folder for analysis step, name accounts for dependencies
            obj.folder = fullfile(analysis_folder, obj.get_name());
            if ~exist(obj.folder,'dir')
                mkdir(obj.folder)
            end
            
            nprops = length(p.Results.properties);
            if nargout < nprops
                error(['ftb:' mfilename],...
                    'not enough output arguments');
            end
            
            % set up file for each property
            varargout = cell(nprops,1);
            for i=1:nprops
                property = p.Results.properties{i};
                varargout{i} = fullfile(obj.folder, [property '.mat']);
            end
            
        end
    end
    
    methods (Abstract)
        init(obj, params)
        process(obj)
        plot(obj, elements)
        add_prev(obj, prev)
    end
    
end

