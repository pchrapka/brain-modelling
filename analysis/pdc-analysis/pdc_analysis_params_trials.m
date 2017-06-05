%% pdc_analysis_params_trials

params = [];
k=1;

%% envelope

params(k).downsample = 4;
params(k).metrics = {'diag'};
params(k).ntrials = [2 5 10 15 20 40];
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;

%% mode
mode = 'tune';
flag_plot = false;
flag_bootstrap = false;

%% set up eeg

stimulus = 'std';
subject = 3;
deviant_percent = 10;
patch_options = {...
    'patchmodel','aal-coarse-19',...
    'patchoptions',{'outer',true,'cerebellum',false,'flag_add_auditory',true}};

out = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_options);

%% run variations
pdc_analysis_variations(...
    out.file_sources,...
    out.file_sources_info,...
    params,...
    'outdir',out.outdir_sources,...
    'mode',mode,...
    'flag_plot_seed',flag_plot,...
    'flag_plot_conn',flag_plot,...
    'flag_bootstrap',flag_bootstrap);