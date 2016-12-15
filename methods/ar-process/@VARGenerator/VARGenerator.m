classdef VARGenerator < handle
    
    properties (SetAccess = protected)
        process_name;
        nchannels;
        version;
        
        hasprocess;
        process;
        nsamples;
    end
    
    methods (Access = protected)
        %data = gen_var_no_coupling(obj,varargin);
        data = gen_vrc_cp_ch2_coupling1_fixed(obj,varargin);
        data = gen_vrc_cp_ch2_coupling2_rnd(obj,varargin);
        data = gen_vrc_coupling0_fixed(obj,varargin);
        
        data = gen_process(obj, process, varargin)
    end
    
    methods
        
        function obj = VARGenerator(process_name, nchannels, varargin)
            %VARGenerator cosntructor
            %   VARGenerator(process_name, nchannels, ...)
            %
             %   Input
            %   -----
            %   process_name (string)
            %       data name,
            %       options:
            %       vrc-coupling0-fixed
            %           2 independent VRC processes
            %       vrc-cp-ch2-coupling2-rnd
            %           a VRCConstPulse process on 2 channels with 2
            %           coupling coefficients, each process and coupling
            %           coefficient is generated randomly
            %       vrc-cp-ch2-coupling1-fixed
            %           a VRCConstPulse process on 2 channels with 1
            %           coupling coefficient, the processes and coupling
            %           coefficient are fixed
            %   nchannels (integer)
            %       number of channels
            %
            %   Parameter
            %   ---------
            %   version (default = 1)
            %       version number
            
            p = inputParser();
            addRequired(p,'process_name',@ischar);
            addRequired(p,'nchannels',@isnumeric);
            addParameter(p,'version',1,@(x) isnumeric(x) || ischar(x));
            p.parse(process_name, nchannels,varargin{:});
            
            obj.process_name = p.Results.process_name;
            obj.nchannels = p.Results.nchannels;
            obj.version = p.Results.version;
            obj.hasprocess = false;
            obj.process = [];
            obj.nsamples = 0;
            
            outfile_sim = obj.get_file();
            if exist(outfile_sim,'file')
                fprintf('generator exists\n');
                obj.hasprocess = true;
            end
        end
        
        function configure(obj,varargin)
            %CONFIGURE configures the VAR or VRC process
            %   CONFIGURE configures the VAR or VRC process based on the
            %   process_name specified in the constructor
            %
            %   Parameters
            %   ----------
            %   built-in process
            %   ----------------
            %   additional parameters may be required based on the
            %   process_name, see TODO for more info
            %
            %   user process
            %   ------------
            %   process (VARProcess, default = [])
            %       custom process
            %   nsamples (integer, default = 500)
            %       number of samples
            
            p = inputParser();
            p.KeepUnmatched = true;
            addParameter(p,'process',[],@(x) isa(x,'VARProcess'));
            addParameter(p,'nsamples',500,@isnumeric);
            parse(p,varargin{:});
            
            if obj.hasprocess
                error('process already specified');
            else
                switch obj.process_name
                    case 'var-no-coupling'
                        [obj.process,obj.nsamples] = obj.gen_var_no_coupling(varargin{:});
                    case 'vrc-coupling0-fixed'
                        [obj.process,obj.nsamples] = obj.gen_vrc_coupling0_fixed(varargin{:});
                    case 'vrc-cp-ch2-coupling2-rnd'
                        [obj.process,obj.nsamples] = obj.gen_vrc_cp_ch2_coupling2_rnd(varargin{:});
                    case 'vrc-cp-ch2-coupling1-fixed'
                        [obj.process,obj.nsamples] = obj.gen_vrc_cp_ch2_coupling1_fixed(varargin{:});
                    otherwise
                        obj.process = p.Results.process;
                        obj.nsamples = p.Results.nsamples;
                end
                obj.hasprocess = true;
            end
        end
        
        function data = generate(obj,varargin)
            %GENERATE generates VAR data
            %   GENERATE(obj) generates VAR data
            %
            %   Parameters
            %   ----------
            %   ntrials (integer, default = 100)
            %       number of trials to generate
            
            p = inputParser();
            addParameter(p,'ntrials',100,@isnumeric);
            p.parse(varargin{:});
            
            % get the data file
            outfile_sim = obj.get_file();
            [~,slug_sim,~] = fileparts(outfile_sim);
            
            % check if file exists
            if ~exist(outfile_sim,'file')
                % if it doesn't, simulate data
                fprintf('simulating: %s\n', slug_sim);
                
                if obj.hasprocess
                    % FIXME nsamples should be fixed from somewhere
                    data = obj.gen_process(...
                        obj.process,varargin{:},...
                        'nsamples',obj.nsamples);
                    % save data
                    save_parfor(outfile_sim, data);
                else
                    error('configure process first');
                end
                
            else
                % otherwise load data
                fprintf('loading: %s\n', slug_sim);
                
                % load data
                data = loadfile(outfile_sim);
                ntime = size(data.signal,2);
                
                data_updated = obj.gen_process(...
                    data.process,...
                    'data',data,...
                    'ntrials',p.Results.ntrials,...
                    'nsamples',ntime);
                
                % save new data
                save_parfor(outfile_sim, data_updated);
            end
            
        end
        
        function outfile = get_file(obj)
            
            if isnumeric(obj.version)
                format_string = '%s-c%d-v%d.mat';
            elseif ischar(obj.version)
                format_string = '%s-c%d-v%s.mat';
            else
                error('unknown version type');
            end
            
            outfile = fullfile(get_project_dir(), 'experiments', 'output-common', 'simulated',...
                sprintf(format_string, obj.process_name, obj.nchannels, obj.version));
        end
        
    end
    
end