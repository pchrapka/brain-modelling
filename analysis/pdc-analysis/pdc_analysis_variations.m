%% pdc_analysis_variations

params = [];
k=1;

%% aal
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal';
% params(k).metrics = {'euc','diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-4;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;


%% aal-coarse-19
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal-coarse-19';
% params(k).metrics = {'euc','diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-1;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;

%% aal-coarse-19 envelope
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal-coarse-19';
% params(k).metrics = {'euc','diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

%% aal-coarse-19-plus2 envelope
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal-coarse-19-plus2';
% params(k).metrics = {'euc','diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

% lots of deep activity still

%% aal-coarse-19-outer-plus
% params(k).patch_type = 'aal-coarse-19-outer-plus2';
% params(k).metrics = {'euc','diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;

% look similar to envelope, except you can see the beta modulation

%% aal-coarse-19-outer-plus2 envelope
% params(k).patch_type = 'aal-coarse-19-outer-plus2';
% params(k).metrics = {'euc','diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% 
% % looks ok, prefrontal is still pretty hot and not really symmetric

%% aal-coarse-19-outer-plus, 40 trials

params(k).patch_type = 'aal-coarse-19-outer-plus2';
params(k).metrics = {'euc','diag','info'};
params(k).ntrials = 40;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = false;
k = k+1;

%% aal-coarse-19-outer-plus2 envelope, 40 trials
params(k).patch_type = 'aal-coarse-19-outer-plus2';
params(k).metrics = {'euc','diag','info'};
params(k).ntrials = 40;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
k = k+1;

%%
flag_run = false;

flag_tune = true;

%% tune order
flag_tune_order = true;
flag_tune_lambda = false;
flag_tune_gamma = false;

%% tune lambda and gamma
% flag_tune_order = false;
% flag_tune_lambda = true;
% flag_tune_gamma = true;

%%
for i=1:length(params)
    
    stimulus = 'std';
    subject = 3;
    deviant_percent = 10;
    
    [pipeline,outdir] = eeg_processall_andrew(...
        stimulus,subject,deviant_percent,params(i).patch_type);
    
    if flag_tune
        if flag_tune_order
            params2 = params(i);
            params2 = rmfield(params2,'metrics');
            
            params2.order = 1:14;
            params2.lambda = 0.99;
            params2.gamma = 1e-2;
            
            params2.plot = true;
            params2.plot_crit = 'ewaic';
            params2.plot_orders = params2.order;
            
            params_func = struct2namevalue(params2);
            tune_model_order(pipeline,outdir,params_func{:});
        end
        
        if flag_tune_lambda
            params2 = params(i);
            params2 = rmfield(params2,'metrics');
            
            params2.order = 6;
            params2.lambda = [0.9:0.02:0.98 0.99];
            params2.gamma = 1e-2;
            
            params2.plot = true;
            params2.plot_crit = 'normtime';
            params2.plot_orders = [1 2 3 4];
            
            params_func = struct2namevalue(params2);
            tune_lambda(pipeline,outdir,params_func{:});
        end
        
        if flag_tune_gamma
            params2 = params(i);
            params2 = rmfield(params2,'metrics');
            
            params2.order = 6;
            params2.lambda = 0.99;
            params2.gamma = [1e-4 1e-3 1e-2 0.1 1 10];
            
            params2.plot = true;
            params2.plot_crit = 'normtime';
            params2.plot_orders = [1 2 3 4];
            
            params_func = struct2namevalue(params2);
            tune_gamma(pipeline,outdir,params_func{:});
        end
        
    end
    
    if flag_run
        params2 = params(i);
        params2 = rmfield(params2,'metrics');
        for j=1:length(params(i).metrics)
            params2.metric = params(i).metrics{j};
            params_func = struct2namevalue(params2);
            pdc_analysis_main(...
                pipeline,...
                outdir,...
                params_func{:});
        end
    end
end