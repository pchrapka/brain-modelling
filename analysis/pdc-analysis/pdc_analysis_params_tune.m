%% pdc_analysis_params_tune

params = [];
k=1;

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = 1:15;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
k = k+1;

%% tune order
flag_run = false;
flag_tune = true;
flag_tune_order = true;
flag_tune_lambda = false;
flag_tune_gamma = false;
flag_bootstrap = false;

%% tune lambda
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = true;
% flag_tune_gamma = false;
% flag_bootstrap = false;

%% tune gamma
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = false;
% flag_tune_gamma = true;
% flag_bootstrap = false;

%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune,...
    'flag_tune_order',flag_tune_order,...
    'flag_tune_lambda',flag_tune_lambda,...
    'flag_tune_gamma',flag_tune_gamma,...
    'flag_bootstrap',flag_bootstrap);