classdef VARGenerator < handle
    
    properties (SetAccess = protected)
        data_name;
        nchannels;
        nsims;
        version;
    end
    
    methods (Access = protected)
        data = gen_var_no_coupling(obj,varargin);
        data = gen_vrc_cp_ch2_coupling1_fixed(obj,varargin);
        data = gen_vrc_cp_ch2_coupling2_rnd(obj,varargin);
        data = gen_vrc_coupling0_fixed(obj,varargin);
        
        data = gen_process(obj, process, varargin)
    end
    
    methods
        
        function obj = VARGenerator(data_name, nsims, nchannels, varargin)
            %VARGenerator cosntructor
            %   VARGenerator(data_name, nsims, nchannels)
            %
             %   Input
            %   -----
            %   data_name (string)
            %       data name,
            %       options:
            %           'var-no-coupling'
            %   nsims (integer)
            %       number of simulations
            %   nchannels (integer)
            %       number of channels
            %
            %   Parameter
            %   ---------
            %   version (default = 1)
            %       version number
            
            p = inputParser();
            addRequired(p,'data_name',@ischar);
            addRequired(p,'nsims',@isnumeric);
            addRequired(p,'nchannels',@isnumeric);
            addParameter(p,'version',1,@(x) isnumeric(x) || ischar(x));
            p.parse(data_name, nsims, nchannels,varargin{:});
            
            obj.data_name = p.Results.data_name;
            obj.nsims = p.Results.nsims;
            obj.nchannels = p.Results.nchannels;
            obj.version = p.Results.version;
            
            outfile_sim = obj.get_file();
            if exist(outfile_sim,'file')
                fprintf('generator exists\n');
            end
        end
        
        function data = generate(obj,varargin)
            %GENERATE generates VAR data
            %   GENERATE(obj) generates VAR data
            
            p = inputParser();
            p.KeepUnmatched = true;
            addParameter(p,'process',[],@(x) isa(x,'VARProcess'));
            parse(p,varargin{:});
            
            % FIXME this shouldn't have varargin since the parameters are
            % fixed for the generator
            
            % get the data file
            outfile_sim = obj.get_file();
            [~,slug_sim,~] = fileparts(outfile_sim);
            
            % check if file exists
            if ~exist(outfile_sim,'file')
                % if it doesn't, simulate data
                fprintf('simulating: %s\n', slug_sim);
                
                switch obj.data_name
                    case 'var-no-coupling'
                        data = obj.gen_var_no_coupling(varargin{:});
                    case 'vrc-coupling0-fixed'
                        data = obj.gen_vrc_coupling0_fixed(varargin{:});
                    case 'vrc-cp-ch2-coupling2-rnd'
                        data = obj.gen_vrc_cp_ch2_coupling2_rnd(varargin{:});
                    case 'vrc-cp-ch2-coupling1-fixed'
                        data = obj.gen_vrc_cp_ch2_coupling1_fixed(varargin{:});
                    otherwise
                        fprintf('generating user process\n');
                        data = obj.gen_process(p.Results.process,...
                            struct2namevalue(p.Results.Unmatched));
                end
                
                % save data
                save_parfor(outfile_sim, data);
                
            else
                % otherwise load data
                fprintf('loading: %s\n', slug_sim);
                
                % load data
                data = loadfile(outfile_sim);
                
                % check if there are enough sims
                nsims_data = size(data.signal,3);
                if nsims_data < obj.nsims
                    fprintf('simulating some more: %s\n', slug_sim);
                    % get the var process object
                    var_process = data.process;
                    ntime = size(data.signal,2);
                    
                    % generate the extra sims
                    for j=nsims_data:obj.nsims
                        [signal, signal_norm,~] = var_process.simulate(ntime);
                        data.signal(:,:,j) = signal;
                        data.signal_norm(:,:,j) = signal_norm;
                    end
                    
                    % save new data
                    save_parfor(outfile_sim, data);
                end
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
                sprintf(format_string, obj.data_name, obj.nchannels, obj.version));
        end
        
    end
    
end