%% pdc_analysis_params_trials

params = [];
k=1;

%% aal-coarse-19-outer-nocer-plus2 envelope

params(k).stimulus = 'std';
params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'diag'};
params(k).ntrials = [2 5 10 15 20 40];
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;

%% run analysis
% flag_run = true;
% flag_tune = false;
% flag_tune_order = false;
% flag_tune_lambda = false;
% flag_tune_gamma = false;
% flag_bootstrap = false;

%% tune trials
flag_run = false;
flag_tune = true;


%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune,...
    'flag_bootstrap',flag_bootstrap);