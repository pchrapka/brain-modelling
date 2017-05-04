%% pdc_analysis_params_bootstrap_test

k = 1;
params = [];

%% aal-coarse-19-outer-nocer-plus2, envelope, eachchannel

% g 1e-6, l 0.99, order 13

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = 4;
params(k).lambda = 0.99;
params(k).gamma = 1;
params(k).normalization = 'eachchannel';
params(k).envelope = true;
params(k).prepend_data = 'flipdata';
params(k).nresamples = 2;
params(k).alpha = 0.05;
params(k).null_mode = 'estimate_ind_channels';
k = k+1;

%% run analysis
flag_run = true;
flag_tune = false;
flag_bootstrap = true;

%% run variations
pdc_analysis_variations(params,...
    'flag_plot_seed',false,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune,...
    'flag_bootstrap',flag_bootstrap);