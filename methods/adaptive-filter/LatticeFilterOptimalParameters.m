classdef LatticeFilterOptimalParameters < handle
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        opt_params_order;
        opt_params_lambda;
        opt_params_gamma;
        opt_params_file;
        tune_file;
        tune_outdir;
    end
    
    methods (Static)
                
        function obj = loadobj(s)
            if isstruct(s)
                obj.opt_params_order = s.opt_params_order;
                obj.opt_params_lambda = s.opt_params_lambda;
                obj.opt_params_gamma = s.opt_params_gamma;
                obj.opt_params_file = s.opt_params_file;
                obj.tune_file = s.tune_file;
                obj.tune_outdir = s.tune_outdir;
            else
                obj = s;
            end
        end
    end
    
    methods
        function obj = LatticeFilterOptimalParameters(tune_file,ntrials)
            
            obj.tune_file = tune_file;
            % create tuning dir
            [tunedir,tunename,~] = fileparts(tune_file);
            obj.tune_outdir = fullfile(tunedir,tunename);
            if ~exist(obj.tune_outdir,'dir')
                mkdir(obj.tune_outdir);
            end
            
            % create file for optimal parameters
            obj.opt_params_file = fullfile(obj.tune_outdir,...
                sprintf('opt-params-ntrials%d.mat',ntrials));
            
            % load or reset opt_params
            obj.opt_params_order = [];
            obj.opt_params_lambda = [];
            obj.opt_params_gamma = [];
            if exist(obj.opt_params_file,'file') && ~isfresh(obj.opt_params_file,tune_file)
                opt_params = loadfile(obj.opt_params_file);
                obj.opt_params_order = opt_params.order;
                obj.opt_params_lambda = opt_params.lambda;
                obj.opt_params_gamma = opt_params.gamma;
            end
        end
        
        function s = saveobj(obj)
            s.opt_params_order = obj.opt_params_order;
            s.opt_params_lambda = obj.opt_params_lambda;
            s.opt_params_gamma = obj.opt_params_gamma;
            s.opt_params_file = obj.opt_params_file;
            s.tune_file = obj.tune_file;
            s.tune_outdir = obj.tune_outdir;
        end
        
        function save(obj)
            data = [];
            data.order = obj.opt_params_order;
            data.lambda = obj.opt_params_lambda;
            data.gamma = obj.opt_params_gamma;
            
            save(obj.opt_params_file, 'data', '-v7.3');
        end
        
        function reset(obj)
            if exist(obj.opt_params_file,'file')
                delete(obj.opt_params_file);
            end
        end
        
        function set_opt(obj,target,value,varargin)
            p = inputParser();
            addRequired(p,'target',@(x) any(validatestring(x,{'order','lambda','gamma'})));
            addRequired(p,'value',@(x) isnumeric(x) && (length(x) == 1));
            addParameter(p,'order',[],@(x) isnumeric(x) && (length(x) == 1));
            addParameter(p,'lambda',[],@(x) isnumeric(x) && (length(x) == 1));
            parse(p,target,value,varargin{:});
            
            params = {};
            if ~isempty(p.Results.order)
                params = [params p.Results.order];
            end
            if ~isempty(p.Results.lambda)
                params = [params p.Results.lambda];
            end
            
            switch p.Results.target
                case 'order'
                    p2 = inputParser();
                    parse(p2,varargin{:});
                    
                    obj.opt_params_order = value;
                case 'lambda'
                    params = {};
                    if ~isempty(p.Results.order)
                        params = [params p.Results.order];
                    end
                    if ~isempty(p.Results.lambda)
                        params = [params, 'lambda', p.Results.lambda];
                    end
                    
                    % requires order
                    p2 = inputParser();
                    addRequired(p2,'order',@(x) isnumeric(x) && (length(x) == 1));
                    parse(p2,params{:});
                    
                    if isempty(obj.opt_params_lambda)
                        idx_new = 1;
                    else
                        idx = ismember(obj.opt_params_lambda(:,1),p2.Results.order);
                        if isempty(idx) || sum(idx) == 0
                            idx_new = size(obj.opt_params_lambda,1)+1;
                        else
                            idx_new = idx;
                        end
                    end
                    
                    obj.opt_params_lambda(idx_new,1) = p2.Results.order;
                    obj.opt_params_lambda(idx_new,2) = value;
                case 'gamma'
                    params = {};
                    if ~isempty(p.Results.order)
                        params = [params p.Results.order];
                    end
                    if ~isempty(p.Results.lambda)
                        params = [params p.Results.lambda];
                    end
                    
                    % requires order and lambda
                    p2 = inputParser();
                    addRequired(p2,'order',@(x) isnumeric(x) && (length(x) == 1));
                    addRequired(p2,'lambda',@(x) isnumeric(x) && (length(x) == 1));
                    parse(p2,params{:});
                    
                    if isempty(obj.opt_params_gamma)
                        idx_new = 1;
                    else
                        idx1 = ismember(obj.opt_params_gamma(:,1),p2.Results.order);
                        idx2 = ismember(obj.opt_params_gamma(:,2),p2.Results.lambda);
                        idx = idx1 & idx2;
                        
                        if isempty(idx) || sum(idx) == 0
                            idx_new = size(obj.opt_params_gamma,1)+1;
                        else
                            idx_new = idx;
                        end
                    end
                    
                    obj.opt_params_gamma(idx_new,1) = p2.Results.order;
                    obj.opt_params_gamma(idx_new,2) = p2.Results.lambda;
                    obj.opt_params_gamma(idx_new,3) = value;
                otherwise
            end
            
            obj.save();
                    
        end
        
        function value = get_opt(obj,target,varargin)
            p = inputParser();
            addRequired(p,'target',@(x) any(validatestring(x,{'order','lambda','gamma'})));
            addParameter(p,'order',[],@(x) isnumeric(x) && (length(x) == 1));
            addParameter(p,'lambda',[],@(x) isnumeric(x) && (length(x) == 1));
            parse(p,target,varargin{:});
            
            switch p.Results.target
                case 'order'
                    p2 = inputParser();
                    parse(p2,varargin{:});
                    
                    value = obj.opt_params_order;
                    if isempty(value)
                        value = NaN;
                    end
                case 'lambda'
                    params = {};
                    if ~isempty(p.Results.order)
                        params = [params p.Results.order];
                    end
                    if ~isempty(p.Results.lambda)
                        params = [params, 'lambda', p.Results.lambda];
                    end
                    
                    % requires order
                    p2 = inputParser();
                    addRequired(p2,'order',@(x) isnumeric(x) && (length(x) == 1));
                    parse(p2,params{:});
                    
                    if isempty(obj.opt_params_lambda)
                        value = NaN;
                    else    
                        idx = ismember(obj.opt_params_lambda(:,1),p2.Results.order);
                        if isempty(idx) || sum(idx) == 0
                            value = NaN;
                        else
                            value = obj.opt_params_lambda(idx,2);
                        end
                    end
                    
                case 'gamma'
                    params = {};
                    if ~isempty(p.Results.order)
                        params = [params p.Results.order];
                    end
                    if ~isempty(p.Results.lambda)
                        params = [params p.Results.lambda];
                    end
                    
                    % requires order and lambda
                    p2 = inputParser();
                    addRequired(p2,'order',@(x) isnumeric(x) && (length(x) == 1));
                    addRequired(p2,'lambda',@(x) isnumeric(x) && (length(x) == 1));
                    parse(p2,params{:});
                    
                    if isempty(obj.opt_params_gamma)
                        value = NaN;
                    else
                        idx1 = ismember(obj.opt_params_gamma(:,1),p2.Results.order);
                        idx2 = ismember(obj.opt_params_gamma(:,2),p2.Results.lambda);
                        idx = idx1 & idx2;
                        if isempty(idx) || sum(idx) == 0
                            value = NaN;
                        else
                            value = obj.opt_params_gamma(idx,3);
                        end
                    end
                    
                otherwise
                    % can't get here because of earlier checks
            end
        end
    end
    
end

