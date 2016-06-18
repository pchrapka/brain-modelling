classdef PipelineLatticeSVM < handle
    %PipelineLatticeSVM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        % PSOM pipeline
        pipeline;
        
        % output directory
        outdir;
        
        config_file;
        config;
    end
    
    properties
        options;
    end
    
    methods
        function obj = PipelineLatticeSVM(outdir)
            % create new PipelineLatticeSVM object
            %   outdir (string)
            %       path for output files
            
            obj.outdir = outdir;
            obj.pipeline = [];
            obj.options = [];
            obj.options.path_logs = fullfile(obj.outdir,'logs');
            
            if ~exist(obj.outdir,'dir')
                mkdir(obj.outdir);
            end
            
            obj.config_file = fullfile(obj.outdir,'config.mat');
            if exist(obj.config_file,'file')
                % load the config if it exists
                obj.config = obj.load_config();
            else
                % create a new one
                obj.init_config();
            end
        end
        
        function run(obj)
            % run the pipeline
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
        
        function job_code = add_job(obj,brick_name,opt_func,varargin)
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
            %   job_code_parent (string, optional)
            %       suffix used as the job name, the default is the name of
            %       the opt_func
            %
            %   specific for each brick
            %   
            %   bricks.select_trials
            %   --------------------
            %   files_in (string)
            %       file containing trial data
            %
            %   bricks.lattice_filter_sources
            %   -----------------------------
            %   files_in (string)
            %       input files
            %
            %   bricks.lattice_features_matrix
            %   ------------------------------
            %   prev_job (struct)
            %       parent job in pipeline
            %
            %   bricks.features_validate
            %   ------------------------
            %   prev_job (struct)
            %       parent job in pipeline
            
            pmain = inputParser;
            pmain.KeepUnmatched = true;
            addParameter(pmain,'job_code_parent','',@(x) ischar(x) || iscell(x));
            % TODO it's possible to have multiple parents
            parse(pmain,varargin{:});
            
            % get brick options from option function
            opt = feval(opt_func);
            
            % add the parameter file
            obj.add_params(brick_name, opt_func);
            
            % get the job name
            job_code = obj.get_job_code(...
                brick_name, opt_func, pmain.Results.job_code_parent);
            
            % get the job dir
            if isfield(obj.pipeline,pmain.Results.job_code_parent)
                % FIXME two parents
                job_dir_parent = obj.pipeline.(pmain.Results.job_code_parent).outdir;
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
            
            switch brick_name
                case 'bricks.select_trials'
                    % varargin: files_in
                    p = inputParser;
                    p.KeepUnmatched = true;
                    addParameter(p,'files_in','',@ischar);
                    parse(p,varargin{:});
                    
                    % temp process of function inputs for number of trials
                    p1 = inputParser;
                    p1.KeepUnmatched = true;
                    addParameter(p1,'trials',100,@isnumeric);
                    addParameter(p1,'label','',@ischar);
                    parse(p1,opt{:});
                    
                    % set up brick
                    files_in = p.Results.files_in;
                    files_out = cell(p1.Results.trials,1);
                    for i=1:p1.Results.trials
                        % create output file name
                        files_out{i} = fullfile(...
                            job_path,...
                            sprintf('trial%d-%s.mat',i,p1.Results.label));
                    end
                    
                case 'bricks.lattice_filter_sources'
                    % varargin: files_in
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'files_in','',@iscell);
                    parse(p,varargin{:});
                    
                    % temp process of function inputs for number of trials
                    % per group
                    p1 = inputParser;
                    p1.KeepUnmatched = true;
                    addParameter(p1,'trials',1,@isnumeric);
                    parse(p1,opt{:});
                    
                    files_in = p.Results.files_in;
                    ntrials = length(files_in);
                    ntrial_groups = floor(ntrials/p1.Results.trials);
                    
                    files_out = cell(ntrial_groups,1);
                    for i=1:ntrial_groups
                        % create output file name
                        if p1.Results.trials > 1
                            files_out{i} = fullfile(job_path,...
                                sprintf('lattice%d.mat',i));
                        else
                            % use the same tag as in the previous step
                            [~,name,~] = fileparts(files_in{i});
                            tag = strrep(name,'trial','');
                            files_out{i} = fullfile(job_path,...
                                sprintf('lattice%s.mat',tag));
                        end
                    end
                    
                case 'bricks.lattice_features_matrix'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'prev_job','',@ischar);
                    % TODO prev job is specified above
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.prev_job).files_out;
                    files_out = fullfile(job_path,...
                        'features-matrix.mat');
                    
                case 'bricks.features_validate'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'prev_job','',@ischar);
                    % TODO prev job is specified above
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.prev_job).files_out;
                    files_out = fullfile(job_path,...
                        'features-validated.mat');

                otherwise
                    obj.print_error('add_job',...
                        'unknown brick %s',brick_name);
            end
            
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
                    brick_name = obj.config.bricks(brick_idx).name;
                else
                    brick_name = results(i).brick_code;
                end
                
                if expand_params
                    params_idx = str2double(results(i).param_code);
                    params_name = obj.config.bricks(brick_idx).params{params_idx}.name;
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
    end
    
    methods (Access = protected)
        function code = get_job_code(obj, brick_name, params_name, job_code_parent)
            %GET_JOB_CODE creates job code based on the brick, parameter
            %file and parent job
            
            % FIXME two parents
            
            brick_code = obj.get_brick_code(brick_name);
            params_code = obj.get_params_code(brick_name, params_name);
            code = [job_code_parent brick_code params_code];
            
        end
        
        function jobdir = get_job_dir(obj, brick_name, params_name, job_dir_parent)
            %GET_JOB_DIR creates job dir based on the brick, parameter file
            %and parent job dir
            
            brick_code = obj.get_brick_code(brick_name);
            if ~isempty(job_dir_parent)
                jobdir = fullfile(job_dir_parent,...
                    [brick_code '-' strrep(params_name,'_','-')]);
            else
                jobdir = [brick_code '-' strrep(params_name,'_','-')];
            end
            
        end
        
        function idx = add_params(obj, brick_name, params_name)
            %ADD_PARAMS add parameter file to the config
            
            brick_idx = obj.get_brick_idx(brick_name);
            idx = obj.get_params_idx(brick_idx,params_name);
            if idx == 0
                if ~isfield(obj.config.bricks(brick_idx),'params')
                    obj.config.bricks(brick_idx).params = [];
                end
                nparams = length(obj.config.bricks(brick_idx).params);
                idx = nparams + 1;
                
                param_new = [];
                param_new.name = params_name;
                param_new.id = sprintf('%02d',idx);
                obj.config.bricks(brick_idx).params{idx} = param_new;
                
                obj.save_config();
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
                code = obj.config.bricks(brick_idx).params{idx}.id;
            end

        end
        
        function idx = get_params_idx(obj, brick_name, params_name)
            %GET_PARAMS_IDX returns the index of the parameter file struct
            %in the config
            
            idx = 0;
            % set the brick index
            if ischar(brick_name)
                brick_idx = obj.get_brick_idx(brick_name);
            else
                brick_idx = brick_name;
            end
            
            % get param array for our brick
            if isfield(obj.config.bricks(brick_idx),'params')
                params = obj.config.bricks(brick_idx).params;
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
            %config
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
            for i=1:length(obj.config.bricks)
                if isequal(obj.config.bricks(i).(field),brick_name)
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
            code = obj.config.bricks(idx).id;
        end
        
        function init_config(obj)
            %INIT_CONFIG initializes the config file
            
            % create one
            obj.config.bricks = [];
            obj.config.bricks(1).name = 'bricks.select_trials';
            obj.config.bricks(1).id = 'st';
            obj.config.bricks(2).name = 'bricks.lattice_filter_sources';
            obj.config.bricks(2).id = 'lf';
            obj.config.bricks(3).name = 'bricks.lattice_features_matrix';
            obj.config.bricks(3).id = 'fm';
            obj.config.bricks(4).name = 'bricks.features_validate';
            obj.config.bricks(4).id = 'fv';
            
            obj.save_config();
        end
        
        
        function config = load_config(obj)
            %LOAD_CONFIG loads config file
            
            if exist(obj.config_file,'file')
                % load it
                din = load(obj.config_file);
                config = din.config;
            else
                warning([mfilename ':load_config'],...
                    'missing config file');
                config = [];
            end
        end
        
        function save_config(obj)
            %SAVE_CONFIG saves config file
            
            config = obj.config;
            save(obj.config_file,'config');
        end
        
    end
    
    methods (Static, Access = protected)
        function print_error(function_name,format,varargin)
            error([mfilename ':' function_name],...
                format, varargin{:});
        end
    end

end

