%% pdc_analysis_params_tune

params = [];
k=1;

%% aal-coarse-19-outer-nocer-plus2, envelope, allchannels
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 1:15;
% params(k).lambda = [0.94 0.96 0.98 0.99 0.995];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1 10];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1];
% params(k).gamma = [1e-6 1e-5 1e-4 1e-3 1e-2 0.1];
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'normtime';
% k = k+1;  

% best is 
%   lambda 0.99
%   gamma 1e-6

% % compare one set
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 1:15;
% % params(k).lambda = [0.94 0.96 0.98 0.99 0.995];
% params(k).lambda = 0.99;
% params(k).gamma = [1e-6 1e-5 1e-4 1e-3 1e-2 0.1];
% % params(k).gamma = 1e-6;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'normtime';
% params(k).plot_orders = 6;
% k = k+1;  

% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-6;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;

% best order 12
% 
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-5;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;
% 
% % best order 11

%% aal-coarse-19-outer-nocer-plus2, envelope, eachchannel
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 1:15;
% params(k).lambda = [0.94 0.96 0.98 0.99 0.995];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1 10];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1];
% params(k).gamma = [1e-6 1e-5 1e-4 1e-3 1e-2 0.1];
% params(k).normalization = 'eachchannel';
% params(k).envelope = true;
% params(k).plot_crit = 'normtime';
% k = k+1;  
% 
% % best is 
% %   lambda 0.99
% %   gamma 1e-6

% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-6;
% params(k).normalization = 'eachchannel';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;
% 
% % best order 13
% 
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-5;
% params(k).normalization = 'eachchannel';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;
% 
% % best order 11

%% tune parameters
flag_run = false;
flag_tune = true;
flag_bootstrap = false;

%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune);