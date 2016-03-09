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
    end
    
    properties(SetAccess = public)
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
    end
    
    methods (Abstract)
        init(obj, params)
        process(obj)
        plot(obj, elements)
        add_prev(obj, prev)
    end
    
end

