%% pdc_analysis_params_tune_std_prestim1

params = [];
k=1;

%% envelope, eachchannel, each trial for warmup
%% new optimization

gammas = [10^(-5) 10^(-4) 10^(-3)];
ngammas = length(gammas);
for j=1:ngammas
    params(k).downsample = 4;
    params(k).metrics = {'diag'};
    params(k).ntrials = 20;
    params(k).order = 3:14;
    params(k).lambda = 0.99;
    params(k).gamma = gammas(j);
    params(k).normalization = 'eachchannel';
    params(k).envelope = true;
    params(k).prepend_data = 'none';
    params(k).nresamples = 100;
    params(k).alpha = 0.05;
    params(k).null_mode = 'estimate_ind_channels';
    k = k+1;
end

%% mode
mode = 'tune';
flag_plot = false;
flag_surrogate = false;

%% set up eeg

stimulus = 'std-prestim1';
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
    'flag_surrogate',flag_surrogate);
