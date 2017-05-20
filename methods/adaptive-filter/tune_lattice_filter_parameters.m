function tune_lattice_filter_parameters(tune_file,outdir,varargin)
%   Input
%   -----
%   tune_file (string)
%       data file for tuning
%   outdir (string)
%       output directory for temp files, the name should reflect the
%       tune_file and the current filter parmeters
%       example:
%           outdir = data-set1/order4/lambda0.99
%
%   Parameters
%   ----------
%
%   filter options
%   --------------
%   filter (string, default = 'MCMTLOCCD_TWL4')
%       lattice filter to be tuned
%   run_options (cell)
%       options for run_lattice_filter function
%   ntrials (integer, defaut = 1)
%       number of trials
%   order (vector, default = 1:14)
%       model orders to evaluate
%   gamma (vector, default = ...)
%       gammas to evaluate
%       TODO deprecated or specific to bayes gamma
%   lambda (vector, default = 0.9:0.02:0.98 0.99)
%       lambdas to evaluate
%   plot (logical, default = false)
%       plot parameter performance
%
%   criteria options
%   -----------------
%   criteria_samples (2x1 vector)
%       starting and ending indices for evaluating criteria

p = inputParser();
p.StructExpand = false;
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'filter','MCMTLOCCD_TWL4',@ischar);
addParameter(p,'run_options',{},@iscell);
addParameter(p,'ntrials',1,@isnumeric);
addParameter(p,'order',1:14,@isnumeric);
gamma_exp = -14:2:1;
default_gamma = [10.^gamma_exp 5 20 30];
default_gamma = sort(default_gamma);
addParameter(p,'gamma',default_gamma,@isnumeric);
default_lambda = [0.9:0.02:0.98 0.99];
addParameter(p,'lambda',default_lambda,@isnumeric);
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
addParameter(p,'plot_gamma',false,@islogical);
addParameter(p,'plot_lambda',false,@islogical);
addParameter(p,'plot_order',false,@islogical);
parse(p,tune_file,outdir,varargin{:});

% get the data folder
comp_name = get_compname();
switch comp_name
    case {'blade16.ece.mcmaster.ca', sprintf('blade16.ece.mcmaster.ca\n')}
        % use old drive
        outdir = strrep(outdir,'home/','home.old/');
        outdir = strrep(outdir,'home-new/','home.old/');
    otherwise
        % do nothing
end

ngamma = length(p.Results.gamma);
nlambda = length(p.Results.lambda);
norder = length(p.Results.order);

[~,tunename,~] = fileparts(tune_file);
tune_outdir = tunename;

% get data size info from tune_file
tune_data = loadfile(tune_file);
[nchannels,~,~] = size(tune_data);
clear tune_data;

trials_dir = sprintf('trials%d',p.Results.ntrials);
outdir_new = fullfile(outdir,tune_outdir,trials_dir);

if (ngamma > 1) && (nlambda > 1) && (norder > 1)
    tune_obj = LatticeFilterOptimalParameters(tune_file,p.Results.ntrials);
    
    lambda_opt = NaN(norder,1);
    gamma_opt_lambda = NaN(norder,1);
    for i=1:norder
        order_cur = p.Results.order(i);
        order_dir = sprintf('order%d',order_cur);
        
        gamma_opt = NaN(nlambda,1);
        parfor j=1:nlambda
            %     for j=1:nlambda
            lambda_cur = p.Results.lambda(j);
            lambda_dir = sprintf('lambda%g',lambda_cur);
            
            % check if i've already optimized gamma for this lambda and order
            % NOTE use object as read-only in inner loop
            tune_obj_inner = LatticeFilterOptimalParameters(tune_file,p.Results.ntrials);
            gamma_opt(j) = tune_obj_inner.get_opt('gamma','order',order_cur,'lambda',lambda_cur);
            if isnan(gamma_opt(j))
                filter_params = [];
                filter_params.nchannels = nchannels;
                filter_params.ntrials = p.Results.ntrials;
                filter_params.norder = order_cur;
                filter_params.lambda = lambda_cur;
                
                % tune gamma
                gamma_opt(j) = tune_lattice_filter_gamma(...
                    tune_file,...
                    fullfile(outdir_new,order_dir,lambda_dir),...
                    'plot_gamma',p.Results.plot_gamma,...
                    'filter','MCMTLOCCD_TWL4',...
                    'filter_params',filter_params,...
                    'run_options',p.Results.run_options,...
                    'upper_bound',max(p.Results.gamma),...
                    'lower_bound',min(p.Results.gamma),...
                    'criteria_samples',p.Results.criteria_samples);
                %             gamma_opt(j) = tune_lattice_filter_gamma_bayesopt(...
                %                 tune_file,...
                %                 fullfile(outdir_new,order_dir,lambda_dir),...
                %                 'plot_gamma_fit',p.Results.plot,...
                %                 'filter','MCMTLOCCD_TWL4',...
                %                 'filter_params',filter_params,...
                %                 'gamma',p.Results.gamma,...
                %                 'run_options',p.Results.run_options,...
                %                 'criteria_samples',p.Results.criteria_samples);
                %tune_obj.set_opt('gamma',gamma_opt(j),'order',order_cur,'lambda',lambda_cur);
            else
                fprintf('already optimized gamma for order %d, lambda %g\n',order_cur,lambda_cur);
            end
        end
        
        % update tune obj with optimal gammas for each lambda
        for j=1:nlambda
            lambda_cur = p.Results.lambda(j);
            tune_obj.set_opt('gamma',gamma_opt(j),'order',order_cur,'lambda',lambda_cur);
        end
        
        % check if i've already optimized lambda for this order
        lambda_opt(i) = tune_obj.get_opt('lambda','order',order_cur);
        if isnan(lambda_opt(i))
            filter_params = [];
            filter_params.nchannels = nchannels;
            filter_params.ntrials = p.Results.ntrials;
            filter_params.norder = order_cur;
            
            % tune lambda
            lambda_opt(i) = tune_lattice_filter_lambda(...
                tune_file,...
                fullfile(outdir_new,order_dir),...
                'filter','MCMTLOCCD_TWL4',...
                'filter_params',filter_params,...
                'lambda',p.Results.lambda,...
                'gamma_opt',gamma_opt,...
                'run_options',p.Results.run_options,...
                'criteria_samples',p.Results.criteria_samples,...
                'plot_lambda',p.Results.plot_lambda);
            tune_obj.set_opt('lambda',lambda_opt(i),'order',order_cur);
        else
            fprintf('already optimized lambda for order %d\n',order_cur);
        end
        gamma_opt_lambda(i) = tune_obj.get_opt('gamma','lambda',lambda_opt(i),'order',order_cur);
        
    end
    
    % check if i've already optimized order
    order_opt = tune_obj.get_opt('order');
    if isnan(order_opt)
        filter_params = [];
        filter_params.nchannels = nchannels;
        filter_params.ntrials = p.Results.ntrials;
        
        % tune order
        order_opt = tune_lattice_filter_order(...
            tune_file,...
            outdir_new,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'order',p.Results.order,...
            'lambda_opt',lambda_opt,...
            'gamma_opt',gamma_opt_lambda,...
            'run_options',p.Results.run_options,...
            'criteria_samples',p.Results.criteria_samples,...
            'plot_order',p.Results.plot_order);
        tune_obj.set_opt('order',order_opt);
    end
    
    fprintf('order opt: %d\n',order_opt);
    lambda_opt = tune_obj.get_opt('lambda','order',order_opt);
    fprintf('lambda opt: %g\n',lambda_opt);
    gamma_opt = tune_obj.get_opt('gamma','lambda',lambda_opt,'order',order_opt);
    fprintf('gamma opt: %g\n',gamma_opt);
    
elseif (ngamma == 1) && (nlambda == 1) && (norder > 1)
    % tune order only
    
    filter_params = [];
    filter_params.nchannels = nchannels;
    filter_params.ntrials = p.Results.ntrials;
    
    % tune order
    order_opt = tune_lattice_filter_order(...
        tune_file,...
        outdir_new,...
        'filter','MCMTLOCCD_TWL4',...
        'filter_params',filter_params,...
        'order',p.Results.order,...
        'lambda_opt',p.Results.lambda,...
        'gamma_opt',p.Results.gamma,...
        'run_options',p.Results.run_options,...
        'criteria_samples',p.Results.criteria_samples,...
        'plot_order',p.Results.plot_order);
    
    fprintf('order opt: %d\n',order_opt);
    
end