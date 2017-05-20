%% pdc_analysis_params_gamma
% run pdc analysis variations for a few gammas

params = [];
k=1;

% gammas = [1e-3 1e-2 1e-1];
gammas = [1e-5 1e-4 1e-3];

for i=1:length(gammas)
%     %% aal-coarse-19-outer-nocer-plus2
%     params(k).stimulus = 'std';
%     params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
%     params(k).metrics = {'diag','info'};
%     params(k).ntrials = 20;
%     params(k).order = 11;
%     params(k).lambda = 0.99;
%     params(k).gamma = gammas(i);
%     params(k).normalization = 'eachchannel';
%     params(k).envelope = false;
%     params(k).prepend_data = 'flipdata';
%     params(k).nresamples = 100;
%     params(k).alpha = 0.05;
%     params(k).null_mode = 'estimate_ind_channels';
%     k = k+1;
    
    %% aal-coarse-19-outer-nocer-plus2 envelope
    params(k).stimulus = 'std';
    params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
    params(k).metrics = {'diag'};%,'info'};
    params(k).ntrials = 20;
    params(k).order = 11;
    params(k).lambda = 0.99;
    params(k).gamma = gammas(i);
    params(k).normalization = 'eachchannel';
    params(k).envelope = true;
    params(k).prepend_data = 'flipdata';
    params(k).nresamples = 100;
    params(k).alpha = 0.05;
    params(k).null_mode = 'estimate_ind_channels';
    k = k+1;
end

%% run analysis
flag_run = true;
flag_plot = true;
flag_tune = false;
flag_bootstrap = false;

%% run variations
pdc_analysis_variations(params,...
    'flag_plot_seed',flag_plot,...
    'flag_run',flag_run,...
    'flag_bootstrap',flag_bootstrap,...
    'flag_tune',flag_tune);