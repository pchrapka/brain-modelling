%% pdc_analysis_params_run_std_prestim1

params = [];
k=1;

%% envelope, eachchannel, each trial for warmup
%% new optimization

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

%% mode
% flag_run = false;
% flag_tune = true;
mode = 'tune';
flag_bootstrap = false;

%% set up eeg

stimulus = 'std-prestim1';
subject = 3;
deviant_percent = 10;
patch_type = 'aal-coarse-19-outer-nocer-plus2';

out = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_type);

% separate following output based on patch model
outdir = fullfile(out.outdir,patch_type);

%% run variations
pdc_analysis_variations(...
    params,...
    'outdir',outdir,...
    'mode',mode,...
    'flag_bootstrap',flag_bootstrap);