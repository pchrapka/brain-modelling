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
        pipeline_options;
    end
    
    methods
        function obj = PipelineLatticeSVM(outdir)
            % create new PipelineLatticeSVM object
            %   outdir (string)
            %       path for output files
            
            obj.outdir = outdir;
            obj.pipeline = [];
            obj.pipeline_options = [];
            
            if ~exist(obj.outdir,'dir')
                mkdir(obj.outdir);
            end
        end
        
        function obj = run(obj)
            % run the pipeline
            %
            %   pipeline options are specified by setting the
            %   pipeline_options property
            %
            %   Example:
            %       obj.pipeline_options.path_logs = fullfile(outdir, 'logs');
            %       obj.pipeline_options.mode = 'background';
            
            psom_run_pipeline(obj.pipeline,obj.pipeline_options);
        end
        
        function prev = last_job(obj)
            prev = obj.pipeline(end);
        end
        
        function obj = add_job(obj,name_brick,opt_func,varargin)
            %
            %   opt_func (string)
            %       function name that generates an option struct for the
            %       brick
            %
            %   Parameters
            %   ----------
            %   specific for each brick
            
            % get brick options from option function
            feval(sprintf('opt=%s();',opt_func));
            
            % get the brick's stage
            stage = obj.get_brick_stage(name_brick);
            % create the job name
            name_job = [stage '-' opt_func];
            
            % set up path for output files
            outbrickpath = fullfile(obj.outdir, name_job);
            if ~exist(outbrickpath,'dir')
                mkdir(outbrickpath);
            end
            
            switch name_brick
                case 'bricks.select_trials'
                    % varargin: trial_list
                    p = inputParser;
                    addParameter(p,'trial_list',{},@iscell);
                    parse(p,varargin{:});
                    
                    % set up brick
                    files_in = p.Results.trial_list;
                    files_out = cell(opt.ntrials,1);
                    for i=1:opt.ntrials
                        files_out{i} = fullfile(...
                            outbrickpath,...
                            sprintf('trial%d.mat',i));
                    end
                    
                case 'bricks.lattice_filter_sources'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    addParameter(p,'prev_job',[],@isstruct);
                    parse(p,varargin{:});
                    
                    files_in = p.Results.prev_job.files_out;
                    ntrials = length(files_in);
                    files_out = cell(ntrials,1);
                    for i=1:ntrials
                        files_out{i} = fullfile(outbrickpath,...
                            sprintf('lattice%d.mat',i));
                    end
                    
                case 'bricks.lattice_features_matrix'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    addParameter(p,'prev_job',[],@isstruct);
                    parse(p,varargin{:});
                    
                    files_in = p.Results.prev_job.files_out;
                    files_out = fullfile(outbrickpath,...
                        'features-matrix.mat');
                    
                case 'bricks.features_validate'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    addParameter(p,'prev_job',[],@isstruct);
                    parse(p,varargin{:});
                    
                    files_in = p.Results.prev_job.files_out;
                    files_out = fullfile(outbrickpath,...
                        'features-validated.mat');

                otherwise
                    error('unknown brick %s',brick_name);
            end
            
            % add the job
            obj.pipeline = psom_add_job(obj.pipeline,name_job,name_brick,...
                        files_in,files_out,opt,false);
            
        end
    end
    
    methods (Static, Access = protected)
        function stage_name = get_brick_stage(brick_name)
            switch brick_name
                case 'bricks.select_trials'
                    stage_name = 'st1st';
                case 'bricks.lattice_filter_sources'
                    stage_name = 'st2lf';
                case 'bricks.features_create_matrix'
                    stage_name = 'st3fm';
                case 'bricks.features_validate'
                    stage_name = 'st4fv';
                otherwise
                    error('unknown brick %s',brick_name);
            end
        end
    end

end

