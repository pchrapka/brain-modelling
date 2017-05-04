%% pdc_analysis_params_tune_mini
flag_test = true;

if flag_test
    ntrials = 5;
    nchannels = 10;
    norder = 8;
    [file_path,~,~] = fileparts(mfilename('fullpath'));
    outdir = fullfile('output','tune-mini-test');
    
    orders = 5;
    lambdas = 0.99;
    gammas = [0.0001 0.1 1 10];
%     gammas_exp = -14:2:1;
%     gammas = [10.^gammas_exp 5 20 30];
%     gammas = sort(gammas);
    
    gen_params = {...
        'vrc-full-coupling-rnd',nchannels,...
        'version','exp39-sparsity0-05'};

    nsamples = 2000;
    gen_config_params = {...
        'order',norder,...
        'nsamples', nsamples,...
        'channel_sparsity', 0.4,...
        'coupling_sparsity', 0.05};
    
    tune_file = tune_file_from_generator(...
        fullfile(file_path,outdir),...
        'gen_params',gen_params,...
        'gen_config_params',gen_config_params,...
        'ntrials',ntrials);
else
    ntrials = 20;
    
    orders = 1:14;
    
    lambdas = [0.94 0.96 0.98 0.99 0.995];
    
    gammas_exp = -14:2:1;
    gammas = [10.^gammas_exp 5 20 30];
    gammas = sort(gammas);
    
    % TODO get file for tuning
end

nlambda = length(lambdas);
norder = length(orders);
ngamma = length(gammas);

% TODO remove extra tuning when creating folder, just use the tune_file
% name
tune_obj = LatticeFilterOptimalParameters(tune_file,ntrials);

% get data size info from tune_file
tune_data = loadfile(tune_file);
[nchannels,nsamples,~] = size(tune_data);

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