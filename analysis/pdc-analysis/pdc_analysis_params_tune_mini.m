%% pdc_analysis_params_tune_mini

ntrials = 20;

if flag_test
    orders = 5;
    lambdas = 0.99;
    gammas = 1;
else
    orders = 1:14;
    
    lambdas = [0.94 0.96 0.98 0.99 0.995];
    
    gammas_exp = -14:2:1;
    gammas = [10.^gammas_exp 5 20 30];
    gammas = sort(gammas);
end

nlambda = length(lambdas);
norder = length(orders);
ngamma = length(gammas);

% TODO get file for tuning

% tune_file = tune_file_from_generator(...
%     fullfile(file_path,outdir),...
%     'gen_params',gen_params,...
%     'gen_config_params',gen_config_params,...
%     'ntrials',ntrials);

% [tunedir,tunename,~] = fileparts(tune_file);
% tune_outdir = fullfile(tunedir,[tunename '-tuning']);
% if ~exist(tune_outdir,'dir')
%     mkdir(tune_outdir);
% end
% 
% file_opt_params = fullfile(tune_outdir,sprintf('opt-params-ntrials%d.mat',ntrials));
% if exist(file_opt_params,'file') && ~isfresh(file_opt_params,tune_file)
%     opt_params = loadfile(file_opt_params);
% else
%     opt_params = [];
%     temp = repmat(orders,nlambda,1);
%     opt_params.gamma = temp(:);
%     opt_params.gamma(:,2) = repmat(lambdas(:),norder,1); 
%     opt_params.gamma(:,3) = NaN;
%     % [order lambda opt_gamma]
%     
%     opt_params.lambda(:,1) = orders(:);
%     opt_params.lambda(:,2) = NaN;
%     % [order opt_lambda]
%     
%     opt_params.order = NaN;
%     % [opt_order]
% end

tune_obj = LatticeFilterOptimalParameters(tune_file,ntrials);

% get data size info from tune_file
tune_data = loadfield(tune_file);
[nchannels,nsamples] = size(tune_data);

filter_params = [];
filter_params.nchannels = nchannels;
filter_params.ntrials = ntrials;

lambda_opt = NaN(norder,1);
for i=1:norder
    order_cur = orders(i);
    
    gamma_opt = NaN(nlambda,1);
    for j=1:nlambda
        lambda_cur = lambdas(j);
        
        % check if i've already optimized gamma for this lambda and order
        gamma_opt(j) = tune_obj.get_opt('gamma','order',order_cur,'lambda',lambda_cur);
        if ~isnan(gamma_opt(j))
            fprintf('already optimized gamma for order %d, lambda %g\n',order_cur,lambda_cur);
            continue;
        end
        
        filter_params.lambda = lambda_cur;
        filter_params.norder = order_cur;
        
        idx_start = floor(nsamples*0.15);
        idx_end = ceil(nsamples*0.95);
        
        gamma_opt(j) = tune_lattice_filter_gamma(...
            tune_file,...
            fullfile(file_path,outdir),...
            'plot_gamma_fit',true,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'gamma',gammas,...
            'run_options',{'warmup_noise', false,'warmup_data', false},...
            'criteria_samples',[idx_start idx_end]);
        tune_obj.set_opt('gamma',gamma_opt(j),'order',order_cur,'lambda',lambda_cur);
        
    end
    
    % check if i've already optimized lambda for this order
    lambda_opt(i) = tune_obj.get_opt('lambda','order',order_cur);
    if ~isnan(lambda_opt(i))
        fprintf('already optimized lambda for order %d\n',order_cur);
        continue;
    end
    
    % tune lambda
    [lambda_opt(i),~] = tune_lattice_filter_lambda();
    tune_obj.set_opt('lambda',lambda_opt(i),'order',order_cur);
    
end

% check if i've already optimized order
order_opt = tune_obj.get_opt('order');
if ~isnan(order_opt)
    fprintf('order opt: %d\n',order_opt);
    lambda_opt = tune_obj.get_opt('lambda','order',order_opt);
    fprintf('lambda opt: %g\n',lambda_opt);
    gamma_opt = tune_obj.get_opt('gamma','lambda',lambda_opt,'order',order_opt);
    fprintf('gamma opt: %g',gamma_opt);
    return;
end

[order_opt,~,~] = tune_lattice_filter_order();
tune_obj.set_opt('order',order_opt);