%% pdc_analysis_params_bootstrap

params = [];
k=1;

%% aal-coarse-19-outer-nocer-plus2 envelope

% NOTE gamma parameter not stable in bootstrapping step
% params(k).stimulus = 'std';
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 12;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-6; % not stable
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).nresamples = 100;
% params(k).alpha = 0.05;
% params(k).null_mode = 'estimate_ind_channels';
% k = k+1;

% % GOOD config
% params(k).stimulus = 'std';
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).downsample = 4;
% params(k).metrics = {'euc','diag'};
% params(k).ntrials = 20;
% params(k).order = 11;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-5;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).nresamples = 100;
% params(k).alpha = 0.05;
% params(k).null_mode = 'estimate_ind_channels';
% k = k+1;

%NOTE null_mode estimate_all_channels can become unstable

%% aal-coarse-19-outer-nocer-plus2, envelope, eachchannel

% g 1e-6, l 0.99, order 13

% % NOTE: lambda = 0.995 gives very little in terms of output
% params(k).stimulus = 'std';
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).downsample = 4;
% params(k).metrics = {'diag','euc','info'};
% params(k).ntrials = 20;
% params(k).order = 7;
% params(k).lambda = 0.995;
% params(k).gamma = 0.38;
% params(k).normalization = 'eachchannel';
% params(k).envelope = true;
% params(k).prepend_data = 'flipdata';
% params(k).nresamples = 100;
% params(k).alpha = 0.05;
% params(k).null_mode = 'estimate_ind_channels';
% k = k+1;

% NOTE bayes opt: gamma 0.733, lambda 0.99, order 11

% new optimization: gamma 0.26, lambda 0.99, order 11, note just tried
% order 11 and lambda 0.99
% new optimization: gamma 0.01, lambda 0.99, order 11, note just tried
% order 11 and lambda 0.99 with [100 1] weighting
% new optimization: gamma 0.0008695, lambda 0.99, order 11, note just tried
% order 11 and lambda 0.99 with [600 1] weighting

params(k).stimulus = 'std';
params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).downsample = 4;
% params(k).metrics = {'diag','euc','info'};
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = 10;
params(k).lambda = 0.94;
params(k).gamma = 1.72377e-06;
params(k).normalization = 'eachchannel';
params(k).envelope = true;
params(k).prepend_data = 'flipdata';
params(k).nresamples = 100;
params(k).alpha = 0.05;
params(k).null_mode = 'estimate_ind_channels';
k = k+1;

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).downsample = 4;
% params(k).metrics = {'diag','euc','info'};
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = 6;
params(k).lambda = 0.99;
params(k).gamma = 7.147e-5;
params(k).normalization = 'eachchannel';
params(k).envelope = true;
params(k).prepend_data = 'flipdata';
params(k).nresamples = 100;
params(k).alpha = 0.05;
params(k).null_mode = 'estimate_ind_channels';
k = k+1;

%% run analysis
flag_run = true;
flag_tune = false;
flag_bootstrap = true;
% flag_bootstrap = false;

%% run variations
pdc_analysis_variations(params,...
    'flag_plot_seed',true,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune,...
    'flag_bootstrap',flag_bootstrap);