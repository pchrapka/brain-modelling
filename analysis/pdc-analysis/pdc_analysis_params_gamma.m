%% pdc_analysis_params_gamma
% run pdc analysis variations for a few gammas

params = [];
k=1;

gammas = [1e-3 1e-2 1e-1];

for i=1:length(gammas)
    %% aal-coarse-19-outer-nocer-plus2
    params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
    params(k).metrics = {'diag','info'};
    params(k).ntrials = 20;
    params(k).order = 3;
    params(k).lambda = 0.99;
    params(k).gamma = gammas(i);
    params(k).normalization = 'allchannels';
    params(k).envelope = false;
    k = k+1;
    
    %% aal-coarse-19-outer-nocer-plus2 envelope
    params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
    params(k).metrics = {'diag','info'};
    params(k).ntrials = 20;
    params(k).order = 3;
    params(k).lambda = 0.99;
    params(k).gamma = gammas(i);
    params(k).normalization = 'allchannels';
    params(k).envelope = true;
    k = k+1;
end

%% run analysis
flag_run = true;
flag_tune = false;
flag_tune_order = false;
flag_tune_lambda = false;
flag_tune_gamma = false;

%% tune order
% flag_run = false;
% flag_tune = true;
% flag_tune_order = true;
% flag_tune_lambda = false;
% flag_tune_gamma = false;

%% tune lambda
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = true;
% flag_tune_gamma = false;

%% tune gamma
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = false;
% flag_tune_gamma = true;

%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune,...
    'flag_tune_order',flag_tune_order,...
    'flag_tune_lambda',flag_tune_lambda,...
    'flag_tune_gamma',flag_tune_gamma);