%% pdc_analysis_params_run_std_prestim1

params = [];
k=1;

%% aal-coarse-19-outer-nocer-plus2, envelope, eachchannel, each trial for warmup
%% new optimization

params(k).stimulus = 'std-prestim1';
params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).downsample = 4;
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = ?;
params(k).lambda = 0.99;
params(k).gamma = 10^(-5);
params(k).normalization = 'eachchannel';
params(k).envelope = true;
params(k).prepend_data = 'none';
params(k).nresamples = 100;
params(k).alpha = 0.05;
params(k).null_mode = 'estimate_ind_channels';
k = k+1;

params(k).stimulus = 'std-prestim1';
params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).downsample = 4;
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = ?;
params(k).lambda = 0.99;
params(k).gamma = 10^(-4);
params(k).normalization = 'eachchannel';
params(k).envelope = true;
params(k).prepend_data = 'none';
params(k).nresamples = 100;
params(k).alpha = 0.05;
params(k).null_mode = 'estimate_ind_channels';
k = k+1;

params(k).stimulus = 'std-prestim1';
params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).downsample = 4;
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = ?;
params(k).lambda = 0.99;
params(k).gamma = 10^(-3);
params(k).normalization = 'eachchannel';
params(k).envelope = true;
params(k).prepend_data = 'none';
params(k).nresamples = 100;
params(k).alpha = 0.05;
params(k).null_mode = 'estimate_ind_channels';
k = k+1;

%% tune parameters
flag_run = false;
flag_tune = true;
flag_bootstrap = false;

%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_bootstrap',flag_bootstrap,...
    'flag_tune',flag_tune);