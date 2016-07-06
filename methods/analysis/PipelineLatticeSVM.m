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
            obj.config.bricks(1).name = 'bricks.add_label';
            obj.config.bricks(1).id = 'al';
            obj.config.bricks(2).name = 'bricks.lattice_filter_sources';
            obj.config.bricks(2).id = 'lf';
            obj.config.bricks(3).name = 'bricks.features_matrix';
            obj.config.bricks(3).id = 'fm';
            obj.config.bricks(4).name = 'bricks.features_validate';
            obj.config.bricks(4).id = 'fv';
            obj.config.bricks(5).name = 'bricks.partition_data';
            obj.config.bricks(5).id = 'pd';
            obj.config.bricks(6).name = 'bricks.features_fdr';
            obj.config.bricks(6).id = 'fd';
            obj.config.bricks(7).name = 'bricks.train_test_common';
            obj.config.bricks(7).id = 'tt';
            
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
            %   bricks.add_label
            %   -----------------------------
            %   files_in (string)
            %       input files
            %
            %   bricks.lattice_filter_sources
            %   -----------------------------
            %   parent_job (string)
            %       parent job in pipeline
            %
            %   bricks.partition_data
            %   -----------------------------
            %   parent_job (string)
            %       parent job in pipeline
            %
            %   bricks.features_matrix
            %   ------------------------------
            %   parent_job (string)
            %       parent job in pipeline
            %
            %   bricks.features_fdr
            %   ------------------------------
            %   parent_job (string)
            %       parent job in pipeline
            %
            %   bricks.features_validate
            %   ------------------------
            %   parent_job (struct)
            %       parent job in pipeline
            %
            %   bricks.train_test_common
            %   ------------------------
            %   parent_job (string)
            %       parent job in pipeline
            %   test_job (string)
            %       test feature matrix job in pipeline
            %   train_job (string)
            %       training feature matrix job in pipeline
            
            opt = feval(opt_func);
            
            switch brick_name
                case 'bricks.add_label'
                    % varargin: files_in
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'files_in',@(x) ~isempty(x));
                    parse(p,varargin{:});
                    
                    files_in = p.Results.files_in;
                    files_out = fullfile(job_path, 'labeled.mat');
                    
                case 'bricks.lattice_filter_sources'
                    % varargin: parent_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'parent_job',@(x) ~isempty(x));
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.parent_job).files_out;
                    files_out = fullfile(job_path, 'lattice-filtered-files.mat');
                    
                case 'bricks.features_matrix'
                    % varargin: parent_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'parent_job',@(x) ~isempty(x));
                    parse(p,varargin{:});
                    
                    files_in = {};
                    for i=1:length(p.Results.parent_job)
                        files_in{i} = obj.pipeline.(p.Results.parent_job{i}).files_out;
                    end
                    files_out = fullfile(job_path, 'features-matrix.mat');
                    
                case 'bricks.partition_data'
                    % varargin: parent_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'parent_job',@(x) ~isempty(x));
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.parent_job).files_out;
                    files_out.test = fullfile(job_path, 'test-feature-matrix.mat');
                    files_out.train = fullfile(job_path, 'train-feature-matrix.mat');
                    
                case 'bricks.features_fdr'
                    % varargin: parent_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'parent_job',@(x) ~isempty(x));
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.parent_job).files_out.train;
                    files_out = fullfile(job_path,...
                        'features-fdr.mat');
                    
                case 'bricks.features_validate'
                    % varargin: parent_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'parent_job','',@ischar);
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.parent_job).files_out;
                    files_out = fullfile(job_path,...
                        'features-validated.mat');
                    
                case 'bricks.train_test_common'
                    % varargin: parent_job,test_job, train_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'parent_job',@(x) ~isempty(x));
                    addParameter(p,'pt_job',@(x) ~isempty(x));
                    addParameter(p,'fdr_job',@(x) ~isempty(x));
                    parse(p,varargin{:});
                    
                    files_in.validated = obj.pipeline.(p.Results.parent_job).files_out;
                    files_in.test = obj.pipeline.(p.Results.pt_job).files_out.test;
                    files_in.train = obj.pipeline.(p.Results.pt_job).files_out.train;
                    files_in.fdr = obj.pipeline.(p.Results.fdr_job).files_out;
                    files_out = fullfile(job_path,...
                        'test-results.mat');

                otherwise
                    obj.print_error('add_job',...
                        'unknown brick %s',brick_name);
            end
        end
        
    end

end

