classdef Pipeline < handle
    %Pipeline Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        % PSOM pipeline
        pipeline;
        
        % output directory
        outdir;
        
        bricks_file;
        bricks;
    end
    
    properties
        options;
    end
    
    methods
        function obj = Pipeline(outdir)
            % create new Pipeline object
            %   outdir (string)
            %       path for output files
            
            obj.outdir = outdir;
            obj.pipeline = [];
            obj.options = [];
            obj.options.path_logs = fullfile(obj.outdir,'logs');
            
            if ~exist(obj.outdir,'dir')
                mkdir(obj.outdir);
            end
            
            obj.bricks_file = fullfile(obj.outdir,'bricks.mat');
            if exist(obj.bricks_file,'file')
                % load the bricks if it exists
                obj.bricks = obj.load_bricks();
            else
                % create a new one
                obj.init_bricks();
                obj.save_bricks();
            end
        end
        
        function run(obj)
            %RUN runs the pipeline
            %   RUN(obj) runs the pipeline
            %
            %   pipeline options are specified by setting the
            %   options property
            %
            %   Example:
            %       obj.options.mode = 'background';
            %
            %   Read only
            %       obj.options.path_logs = fullfile(outdir, 'logs');
            
            obj.options.path_logs = fullfile(obj.outdir,'logs');
            psom_run_pipeline(obj.pipeline,obj.options);
        end
        
        function unlock(obj)
            %UNLOCK unlocks the pipeline
            %   UNLOCK(obj) unlocks the pipeline
            
            warning([mfilename ':unlock'],...
                'make sure you know what you''re doing here');
            
            % checks for the lock file
            lock_file = fullfile(obj.options.path_logs,'PIPE.lock');
            if exist(lock_file,'file')
                delete(lock_file);
            end
            
            % checks for running jobs
            file_running = dir(fullfile(obj.options.path_logs,'*.running'));
            if ~isempty(file_running)
                for i=1:length(file_running)
                    file_name = fullfile(obj.options.path_logs,file_running(i).name);
                    if exist(file_name,'file')
                        delete(file_name);
                    end
                end
            end
            
        end
        
        function job_code = add_job(obj,brick_name,opt_func,varargin)
            %ADD_JOB adds a job to the pipeline
            %   ADD_JOB(obj,brick_name,opt_func,...) adds a job to the
            %   pipeline
            %
            %   Input
            %   -----
            %   brick_name (string)
            %       name of the brick to be used for the job
            %   opt_func (string)
            %       function name that generates an option struct for the
            %       brick
            %
            %   Output
            %   ------
            %   job_code (string)
            %       unique job code for the added job
            %
            %   Parameters
            %   ----------
            %   parent_job (string, optional)
            %       suffix used as the job name, the default is the name of
            %       the opt_func
            %   
            %   You can also add specific parameter for each brick
            
            pmain = inputParser;
            pmain.KeepUnmatched = true;
            addRequired(pmain,'brick_name',@ischar);
            addRequired(pmain,'opt_func',@ischar);
            addParameter(pmain,'parent_job','',@(x) ischar(x) || iscell(x));
            parse(pmain,brick_name,opt_func,varargin{:});
            
            % add the parameter file
            obj.add_params(brick_name, opt_func);
            
            % get the job name
            % NOTE abstract function
            job_code = obj.get_job_code(...
                brick_name, opt_func, pmain.Results.parent_job);
            
            % get the job dir
            if isfield(obj.pipeline,pmain.Results.parent_job)
                if iscell(pmain.Results.parent_job)
                    % if there's more parents pick the first one
                    parent_job = pmain.Results.parent_job{1};
                else
                    parent_job = pmain.Results.parent_job;
                end
                job_dir_parent = obj.pipeline.(parent_job).outdir;
            else
                job_dir_parent = '';
            end
            job_dir = obj.get_job_dir(...
                brick_name, opt_func, job_dir_parent);
            
            % check if job name exists
            if obj.exist_job(job_code)
                % better to throw an error
                obj.print_error('add_job',...
                    'job exists in pipeline: %s',job_code);
            end
            
            % set up path for output files
            job_path = fullfile(obj.outdir, job_dir);
            if ~exist(job_path,'dir')
                mkdir(job_path);
            end
            
            % get job params
            % 
            [files_in,files_out] = obj.get_job_params(...
                brick_name, opt_func, job_path, varargin{:});
            
            % get brick options from option function
            opt = feval(opt_func);
            
            % add the job
            obj.pipeline = psom_add_job(obj.pipeline, job_code ,brick_name,...
                files_in, files_out, opt, false);
            
            % save the job dir
            obj.pipeline.(job_code).outdir = job_dir;
        end
    
        function out = exist_job(obj,job_name)
            %EXIST_JOB checks if job exists
            %   EXIST_JOB(obj, job_name) checks if a job exists in the
            %   pipeline
            %
            %   Input
            %   -----
            %   job_name (string)
            %       job name
            %
            %   Output
            %   ------
            %   out (logical)
            %       true is if exists
            
            out = false;
            if isfield(obj.pipeline,job_name)
                out = true;
            end
        end
        
        function name = expand_code(obj,job_code,varargin)
            %
            %   Parameters
            %   ----------
            %   mode (string, default = names)
            %       expands code into name or nested folder structure,
            %       options = folders, names
            %   expand (string, default = both)
            %       selects parts to expand, options = bricks, params, both
            
            p = inputParser();
            addRequired(p,'job_code',@ischar);
            addParameter(p,'mode','names',...
                @(x)any(validatestring(x,{'folders','names'})));
            addParameter(p,'expand','both',...
                @(x)any(validatestring(x,{'bricks','params','both'})));
            parse(p,job_code,varargin{:});

            name = '';
            
            % parse the job code
            pattern = '(?<brick_code>\w{2,2})(?<param_code>\d{2,2})';
            results = regexp(job_code, pattern, 'names');
            if isempty(results)
                obj.print_error('expand_code',...
                    'unknown code %s', job_code);
            end
            
            expand_bricks = false;
            expand_params = false;
            switch p.Results.expand
                case 'both'
                    expand_bricks = true;
                    expand_params = true;
                case 'bricks'
                    expand_bricks = true;
                case 'params'
                    expand_params = true;
            end
            
            % translate each brick and param group
            for i=1:length(results)
                brick_idx = obj.get_brick_idx(results(i).brick_code,'mode','code');
                
                if expand_bricks
                    brick_name = obj.bricks(brick_idx).name;
                else
                    brick_name = results(i).brick_code;
                end
                
                if expand_params
                    params_idx = str2double(results(i).param_code);
                    params_name = obj.bricks(brick_idx).params{params_idx}.name;
                else
                    params_name = results(i).param_code;
                end
                
                if isempty(name)
                    name = [brick_name '-' params_name];
                else
                    switch p.Results.mode
                        case 'folders'
                            name = fullfile(name,[brick_name '-' params_name]);
                        case 'names'
                            name = [name '-' brick_name '-' params_name];
                    end
                end
                
                if isequal(p.Results.mode,'folders')
                    name = strrep(name,'_','-');
                end
            end
        end
        
        function code = get_params_code(obj, brick_name, params_name)
            %GET_PARAMS_CODE returns the 2 digit parameter file code
            
            code = '';
            if ischar(brick_name)
                brick_idx = obj.get_brick_idx(brick_name);
            else
                brick_idx = brick_name;
            end
            
            idx = obj.get_params_idx(brick_idx,params_name);
            if idx > 0
                code = obj.bricks(brick_idx).params{idx}.id;
            end

        end
        
        function idx = get_params_idx(obj, brick_name, params_name)
            %GET_PARAMS_IDX returns the index of the parameter file struct
            %in the bricks config
            
            idx = 0;
            % set the brick index
            if ischar(brick_name)
                brick_idx = obj.get_brick_idx(brick_name);
            else
                brick_idx = brick_name;
            end
            
            % get param array for our brick
            if isfield(obj.bricks(brick_idx),'params')
                params = obj.bricks(brick_idx).params;
            else
                return;
            end
            
            % search the param array
            for i=1:length(params)
                if isequal(params{i}.name,params_name)
                    idx = i;
                    return
                end
            end
        end
        
        function idx = get_brick_idx(obj, brick_name, varargin)
            %GET_BRICK_IDX returns the index of the brick struct in the
            %bricks config
            %
            %   brick_name (string)
            %       brick name or code, default it's the brick name
            %
            %   Parameters
            %   ----------
            %   mode (string, default = 'name')
            %       describes content of brick_name, options = 'name' or 'code'
            
            p = inputParser();
            addRequired(p,'brick_name',@ischar);
            mode_options = {'name','code'};
            addParameter(p,'mode','name',@(x)any(validatestring(x,mode_options)));
            parse(p,brick_name,varargin{:});
            
            if isequal(p.Results.mode,'code')
                field = 'id';
            else
                field = 'name';
            end
            
            idx = 0;
            for i=1:length(obj.bricks)
                if isequal(obj.bricks(i).(field),brick_name)
                    idx = i;
                    return
                end
            end
            
            if idx == 0
                % brick not found
                obj.print_error('brick %s not found', brick_name);
            end
        end
        
        function code = get_brick_code(obj, brick_name)
            %GET_BRICK_CODE returns 2 letter brick code
            
            idx = obj.get_brick_idx(brick_name);
            code = obj.bricks(idx).id;
        end
        
        function idx = add_params(obj, brick_name, params_name)
            %ADD_PARAMS add parameter file to the bricks config
            
            brick_idx = obj.get_brick_idx(brick_name);
            idx = obj.get_params_idx(brick_idx,params_name);
            if idx == 0
                if ~isfield(obj.bricks(brick_idx),'params')
                    obj.bricks(brick_idx).params = [];
                end
                nparams = length(obj.bricks(brick_idx).params);
                idx = nparams + 1;
                
                param_new = [];
                param_new.name = params_name;
                param_new.id = sprintf('%02d',idx);
                obj.bricks(brick_idx).params{idx} = param_new;
                
                obj.save_bricks();
            end
        end
        
        function add_brick(obj, brick_name, brick_id)
            %ADD_BRICK add brick to the bricks config
            
            % check id
            if length(brick_id) > 2
                obj.print_error('add_brick','brick id is too long, should be 2 characters');
            end
            
            % check if it exists
            for i=1:length(obj.bricks)
                if isequal(obj.bricks(i).id, brick_id)
                    obj.print_error('add_brick','brick id already exists %s',brick_id);
                end
                
                if isequal(obj.bricks(i).name, brick_name)
                    obj.print_error('add_brick','brick name already exists %s',brick_name);
                end
            end
            
            % add if no errors were thrown
            idx = length(obj.bricks) + 1;
            obj.bricks(idx).name = brick_name;
            obj.bricks(idx).id = brick_id;
            
            obj.save_bricks();
        end
    end
    
    methods (Access = protected)
        function code = get_job_code(obj, brick_name, params_name, job_code_parent)
            %GET_JOB_CODE creates job code based on the brick, parameter
            %file and parent job
            
            brick_code = obj.get_brick_code(brick_name);
            params_code = obj.get_params_code(brick_name, params_name);
            if iscell(job_code_parent)
                code_new = [];
                for i=1:length(job_code_parent)
                    code_new = [code_new job_code_parent{i}];
                end
                job_code_parent = code_new;
            end
            code = [job_code_parent brick_code params_code];
            
        end
        
        function jobdir = get_job_dir(obj, brick_name, params_name, job_dir_parent)
            %GET_JOB_DIR creates job dir based on the brick, parameter file
            %and parent job dir
            
            brick_code = obj.get_brick_code(brick_name);
            % remove params_[brick code] prefix
            params_name = strrep(params_name, ['params_' brick_code '_'], '');
            
            if ~isempty(job_dir_parent)
                jobdir = fullfile(job_dir_parent,...
                    [brick_code '-' strrep(params_name,'_','-')]);
            else
                jobdir = [brick_code '-' strrep(params_name,'_','-')];
            end
            
        end
        
        function bricks = load_bricks(obj)
            %LOAD_BRICKS loads bricks file
            
            if exist(obj.bricks_file,'file')
                % load it
                din = load(obj.bricks_file);
                bricks = din.bricks;
            else
                warning([mfilename ':load_bricks'],...
                    'missing bricks file');
                bricks = [];
            end
        end
        
        function save_bricks(obj)
            %SAVE_BRICKS saves bricks file
            
            bricks = obj.bricks;
            save(obj.bricks_file,'bricks');
        end
    
        function print_error(obj,function_name,format,varargin)
            class_name = class(obj);
            error([class_name ':' function_name],...
                format, varargin{:});
        end
    end
    
    methods (Abstract, Access = protected)
        init_bricks(obj)
        %INIT_BRICKS initializes the bricks file with brick names
        
        [files_in,files_out] = get_job_params(obj,brick_name,opt_func,job_path,varargin)
        %GET_JOB_PARAMS returns job parameters
    end

end

