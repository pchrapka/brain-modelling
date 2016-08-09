classdef VARGenerator < handle
    
    properties (SetAccess = protected)
        data_name;
        nchannels;
        nsims;
    end
    
    methods (Access = protected)
        data = gen_var_no_coupling(obj,varargin);
        data = gen_vrc_ch2_coupling1_fixed(obj,varargin);
        data = gen_vrc_ch2_coupling2_rnd(obj,varargin);
        
        data = gen_process(obj, process, varargin)
    end
    
    methods
        
        function obj = VARGenerator(data_name, nsims, nchannels)
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
            
            p = inputParser();
            addRequired(p,'data_name',@ischar);
            addRequired(p,'nsims',@isnumeric);
            addRequired(p,'nchannels',@isnumeric);
            p.parse(data_name, nsims, nchannels);
            
            obj.data_name = p.Results.data_name;
            obj.nsims = p.Results.nsims;
            obj.nchannels = p.Results.nchannels;
        end
        
        function data = generate(obj,varargin)
            %GENERATE generates VAR data
            %   GENERATE(obj) generates VAR data
            
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
                    case 'vrc-ch2-coupling2-rnd'
                        data = obj.gen_vrc_ch2_coupling2_rnd(varargin{:});
                    case 'vrc-ch2-coupling1-fixed'
                        data = obj.gen_vrc_ch2_coupling1_fixed(varargin{:});
                    otherwise
                        error('unknown data name %s',obj.data_name);
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
            
            outfile = fullfile(get_project_dir(), 'experiments', 'output-common', 'simulated',...
                sprintf('%s-c%d.mat', obj.data_name, obj.nchannels));
        end
        
    end
    
end