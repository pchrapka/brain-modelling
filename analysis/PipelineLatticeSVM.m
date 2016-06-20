classdef PipelineLatticeSVM < Pipeline
    %PipelineLatticeSVM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = PipelineLatticeSVM(outdir)
            % create new PipelineLatticeSVM object
            %   outdir (string)
            %       path for output files
            
            obj = obj@Pipeline(outdir);
           
        end
        
        
    
    end
    
    methods (Access = protected)
        
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
            
        end
        
        function [files_in,files_out] = get_job_params(obj,brick_name,opt_func,job_path,varargin)
            %GET_JOB_PARAMS returns job parameters
            %   GET_JOB_PARAMS(obj,brick_name,opt_func,...) returns job
            %   parameters
            %
            %   Input
            %   -----
            %   brick_name (string)
            %       brick name
            %   opt_func (string)
            %       function name that generates an option struct for the
            %       brick
            %
            %   Output
            %   ------
            %   files_in (cell array)
            %       list of input files for the job
            %   files_out (cell array)
            %       list of output files for the job
            %
            %   Parameters
            %   ----------
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
            
            opt = feval(opt_func);
            
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
        end
        
    end

end

