%% pdc_analysis_variations

params = [];
k=1;

%% aal
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal';
% params(k).metrics = {'diag','info'};
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
% params(k).metrics = {'diag','info'};
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
% params(k).metrics = {'diag','info'};
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
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

% lots of deep activity still

%% aal-coarse-19-outer-nocer-plus2
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;

% aal-coarse-19-outer-plus2
% look similar to envelope, except you can see the beta modulation

%% aal-coarse-19-outer-nocer-plus2 envelope
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% 
% % aal-coarse-19-outer-plus2
% % looks ok, prefrontal is still pretty hot and not really symmetric

%% aal-coarse-19-outer-plus, 40 trials

% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 40;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;

%% aal-coarse-19-outer-nocer-plus2 envelope, 40 trials

% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 40;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

%% aal-coarse-19-outer-plus, 60 trials

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'diag','info'};
params(k).ntrials = 60;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = false;
k = k+1;

%% aal-coarse-19-outer-nocer-plus2 envelope, 60 trials

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'diag','info'};
params(k).ntrials = 60;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
k = k+1;

%% run analysis
flag_run = true;
flag_tune = false;

%% tune order
% flag_run = false;
% flag_tune = true;
% flag_tune_order = true;
% flag_tune_lambda = false;
% flag_tune_gamma = false;

%% tune lambda
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = true;
% flag_tune_gamma = false;

%% tune gamma
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = false;
% flag_tune_gamma = true;

%%
for i=1:length(params)
    
    stimulus = 'std';
    subject = 3;
    deviant_percent = 10;
    
    [pipeline,outdirbase] = eeg_processall_andrew(...
        stimulus,subject,deviant_percent,params(i).patch_type);
    
    % separate following output based on patch model
    outdir = fullfile(outdirbase,params(i).patch_type);
    
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
        % copy params
        params2 = params(i);
        % remove metrics field
        params2 = rmfield(params2,'metrics');
        
        % loop over metrics
        for j=1:length(params(i).metrics)
            
            % select lf params
            params_lf = copyfields(params2,[],...
                {'ntrials','order','lambda','gamma','normalization','envelope'});
            params_func = struct2namevalue(params_lf);
            lf_files = lf_analysis_main(pipeline, outdir, params_func{:});
            
            % select pdc params
            params_pdc = copyfields(params2,[],...
                {'metric','patch_type','envelope'});
            % change metric
            params_pdc.metric = params(i).metrics{j};
            params_func = struct2namevalue(params_pdc);
            
            eeg_file = fullfile(outdirbase,'fthelpers.ft_phaselocked.mat');
            pdc_analysis_main(pipeline, lf_files, eeg_file, params_func{:});
        end
    end
end