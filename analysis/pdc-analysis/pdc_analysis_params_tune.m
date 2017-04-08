%% pdc_analysis_params_tune

params = [];
k=1;
% 
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 1:15;
% params(k).lambda = [0.96 0.98 0.99 0.995 0.999];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1 10];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1];
% params(k).gamma = [1e-4 1e-3 1e-2 0.1];
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'normtime';
% k = k+1;  

% best is 
%   lambda 0.995, 
%   gamma 1e-4, 1e-3


params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = 2:15;
params(k).lambda = 0.995;
params(k).gamma = 1e-4;
params(k).normalization = 'allchannels';
params(k).envelope = true;
params(k).plot_crit = 'ewaic';
k = k+1;

% best order 6

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = 2:15;
params(k).lambda = 0.995;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
params(k).plot_crit = 'ewaic';
k = k+1;

% best order 6

%% tune order
flag_run = false;
flag_tune = true;
% flag_tune_order = true;
% flag_tune_lambda = false;
% flag_tune_gamma = false;
flag_bootstrap = false;

%% tune lambda
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = true;
% flag_tune_gamma = false;
% flag_bootstrap = false;

%% tune gamma
% flag_run = false;
% flag_tune = true;
% flag_tune_order = false;
% flag_tune_lambda = false;
% flag_tune_gamma = true;
% flag_bootstrap = false;

%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune);
%     'flag_tune_order',flag_tune_order,...
%     'flag_tune_lambda',flag_tune_lambda,...
%     'flag_tune_gamma',flag_tune_gamma,...
%     'flag_bootstrap',flag_bootstrap);