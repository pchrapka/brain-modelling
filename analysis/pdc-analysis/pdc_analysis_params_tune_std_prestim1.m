%% pdc_analysis_params_tune_std_prestim1

params = [];
k=1;

%% aal-coarse-19-outer-nocer-plus2, envelope, eachchannel, each trial for warmup
%% new optimization

gammas = [10^(-5) 10^(-4) 10^(-3)];
ngammas = length(gammas);
for j=1:ngammas
    params(k).stimulus = 'std-prestim1';
    params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
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

%% tune parameters
flag_run = false;
flag_tune = true;
flag_bootstrap = false;

%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_bootstrap',flag_bootstrap,...
    'flag_tune',flag_tune);