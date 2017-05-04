%% pdc_analysis_params_bootstrap

params = [];
k=1;

%% aal-coarse-19-outer-nocer-plus2 envelope

% NOTE gamma parameter not stable in bootstrapping step
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
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
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
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

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'euc','diag','info'};
params(k).ntrials = 20;
params(k).order = 11;
params(k).lambda = 0.99;
params(k).gamma = 1e-5;
params(k).normalization = 'eachchannel';
params(k).envelope = true;
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