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
            %   specific for each brick
            %   
            %   bricks.select_trials
            %   --------------------
            %   trials_file (string)
            %       file containing trial data
            %
            %   bricks.lattice_filter_sources
            %   bricks.lattice_features_matrix
            %   bricks.features_validate
            %   ------------------------
            %   prev_job (struct)
            %       parent job in pipeline
            
            
            % get brick options from option function
            opt = feval(opt_func);
            
            % get the brick's stage
            stage = obj.get_brick_stage(name_brick);
            % create the job name
            name_job = [stage '_' opt_func];
            
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
                    
                    files_in = p.Results.files_in;
                    ntrials = length(files_in);
                    files_out = cell(ntrials,1);
                    for i=1:ntrials
                        % use the same tag as in the previous step
                        [~,name,~] = fileparts(files_in{i});
                        tag = strrep(name,'trial','');
                        % create output file name
                        files_out{i} = fullfile(outbrickpath,...
                            sprintf('lattice%s.mat',tag));
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
