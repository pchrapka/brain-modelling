classdef VARGenerator < handle
    
    properties (SetAccess = protected)
        data_name;
        nchannels;
        nsims;
    end
    
    methods (Access = protected)
        data = gen_var_no_coupling(obj);
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
                    case 'vrc-2ch-coupling'
                        data = obj.gen_vrc_2ch_coupling(varargin{:});
                    otherwise
                        error('unknown data name %s',obj.data_name);
                end
                % save data
                save_parfor(outfile_sim,data);
                
            else
                % otherwise load data
                fprintf('loading: %s\n', slug_sim);
                
                % load data
                data = loadfile(outfile_sim);
            end
            
        end
        
        function outfile = get_file(obj)
            
            outfile = fullfile(get_project_dir(), 'experiments', 'output-common', 'simulated',...
                sprintf('%s-c%d.mat', obj.data_name, obj.nchannels));
        end
        
    end
    
end