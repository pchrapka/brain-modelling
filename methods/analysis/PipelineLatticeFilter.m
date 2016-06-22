classdef PipelineLatticeFilter < Pipeline
    %PipelineLatticeFilter Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = PipelineLatticeFilter(outdir)
            % create new PipelineLatticeFilter object
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
            obj.config.bricks(1).name = 'bricks.lattice_filter_sources';
            obj.config.bricks(1).id = 'lf';
            obj.config.bricks(2).name = 'bricks.add_label';
            obj.config.bricks(2).id = 'al';
            
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
            %   prev_job (string)
            %       previous job
            
            opt = feval(opt_func);
            
            switch brick_name
                case 'bricks.add_label'
                    % varargin: files_in
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'files_in','',@ischar);
                    parse(p,varargin{:});
                    
                    files_out = fullfile(job_path, 'labeled.mat');
                    
                case 'bricks.lattice_filter_sources'
                    % varargin: prev_job
                    p = inputParser;
                    p.StructExpand = false;
                    p.KeepUnmatched = true;
                    addParameter(p,'prev_job','',@ischar);
                    parse(p,varargin{:});
                    
                    files_in = obj.pipeline.(p.Results.prev_job).files_out;
                    files_out = fullfile(job_path, 'lattice-filtered-files.mat');
                    
                otherwise
                    obj.print_error('add_job',...
                        'unknown brick %s',brick_name);
            end
        end
        
    end

end

