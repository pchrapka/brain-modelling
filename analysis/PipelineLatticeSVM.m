classdef PipelineLatticeSVM < handle
    %PipelineLatticeSVM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        % PSOM pipeline
        pipeline;
        
        % output directory
        outdir;
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
            
            if ~exist(obj.outdir,'dir')
                mkdir(obj.outdir);
            end
        end
        
        function obj = run(obj)
            % run the pipeline
            %
            %   pipeline options are specified by setting the
            %   options property
            %
            %   Example:
            %       obj.options.path_logs = fullfile(outdir, 'logs');
            %       obj.options.mode = 'background';
            
            psom_run_pipeline(obj.pipeline,obj.options);
        end
        
        function [obj,name_job] = add_job(obj,name_brick,opt_func,varargin)
            %
            %   opt_func (string)
            %       function name that generates an option struct for the
            %       brick
            %
            %   Parameters
            %   ----------
            %   job_name (string, optional)
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
            addParameter(pmain,'job_name','',@ischar);
            parse(pmain,varargin{:});
            
            % get brick options from option function
            opt = feval(opt_func);
            
            % get the brick's stage
            stage = obj.get_brick_stage(name_brick);
            % create the job name
            if isempty(pmain.Results.job_name)
                name_job = [stage '_' opt_func];
            else
                name_job = [stage '_' pmain.Results.job_name];
            end
            
            % check if job name exists
            if obj.exist_job(name_job)
                % better to throw an error
                error([mfilename ':add_job',...
                    'job name exists in pipeline: %s',name_job);
%                 % get the job name count
%                 if isfield(obj.pipeline.(name_job),'count')
%                     count = obj.pipeline.(name_job).count + 1;
%                 else
%                     count = 1;
%                 end
%                 % save the count
%                 obj.pipeline.(name_job).count = count;
%                 
%                 % add a temp number to the job name
%                 name_job_orig = name_job;
%                 name_job = [name_job_orig '_' num2str(count)];
%                 
%                 fprintf([...
%                     '%s.add_job:\n\t'...
%                     'job name already exists\n\t'...
%                     'modified %s -> %s\n'],...
%                     mfilename, name_job_orig, name_job);
            end
            
            % set up path for output files
            outbrickpath = fullfile(obj.outdir, strrep(name_job,'_','-'));
            if ~exist(outbrickpath,'dir')
                mkdir(outbrickpath);
            end
            
            switch name_brick
                case 'bricks.select_trials'
                    % varargin: trials_file
                    p = inputParser;
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
                            outbrickpath,...
                            sprintf('trial%d-%s.mat',i,p1.Results.label));
                    end
                    
                case 'bricks.lattice_filter_sources'
                    % varargin: files_in
                    p = inputParser;
                    p.StructExpand = false;
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
                            files_out{i} = fullfile(outbrickpath,...
                                sprintf('lattice%d.mat',i));
                        else
                            % use the same tag as in the previous step
                            [~,name,~] = fileparts(files_in{i});
                            tag = strrep(name,'trial','');
                            files_out{i} = fullfile(outbrickpath,...
                                sprintf('lattice%s.mat',tag));
                        end
                    end
                    
                case 'bricks.lattice_features_matrix'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    addParameter(p,'prev_job','',@ischar);
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.prev_job).files_out;
                    files_out = fullfile(outbrickpath,...
                        'features-matrix.mat');
                    
                case 'bricks.features_validate'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    addParameter(p,'prev_job','',@ischar);
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.prev_job).files_out;
                    files_out = fullfile(outbrickpath,...
                        'features-validated.mat');

                otherwise
                    error('unknown brick %s',brick_name);
            end
            
            % add the job
            obj.pipeline = psom_add_job(obj.pipeline,name_job,name_brick,...
                files_in,files_out,opt,false);
            
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
    end
    
    methods (Static, Access = protected)
        function stage_name = get_brick_stage(brick_name)
            switch brick_name
                case 'bricks.select_trials'
                    stage_name = 'st1st';
                case 'bricks.lattice_filter_sources'
                    stage_name = 'st2lf';
                case 'bricks.lattice_features_matrix'
                    stage_name = 'st3fm';
                case 'bricks.features_validate'
                    stage_name = 'st4fv';
                otherwise
                    error('unknown brick %s',brick_name);
            end
        end
    end

end

