%% pdc_analysis_params

params = [];
k=1;

%% aal
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-4;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;


%% aal-coarse-19
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal-coarse-19';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-1;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;

%% aal-coarse-19 envelope
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal-coarse-19';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

%% aal-coarse-19-plus2 envelope
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal-coarse-19-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

% lots of deep activity still

%% aal-coarse-19-outer-nocer-plus2
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;

% aal-coarse-19-outer-plus2
% look similar to envelope, except you can see the beta modulation

%% aal-coarse-19-outer-nocer-plus2 envelope
% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% 
% % aal-coarse-19-outer-plus2
% % looks ok, prefrontal is still pretty hot and not really symmetric

%% aal-coarse-19-outer-plus, 40 trials

% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 40;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;

%% aal-coarse-19-outer-nocer-plus2 envelope, 40 trials

% params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
% params(k).downsample = 4;
% params(k).metrics = {'diag','info'};
% params(k).ntrials = 40;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

%% aal-coarse-19-outer-plus, 60 trials

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).downsample = 4;
params(k).metrics = {'diag','info'};
params(k).ntrials = 60;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = false;
k = k+1;

%% aal-coarse-19-outer-nocer-plus2 envelope, 60 trials

params(k).patch_type = 'aal-coarse-19-outer-nocer-plus2';
params(k).downsample = 4;
params(k).metrics = {'diag','info'};
params(k).ntrials = 60;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
k = k+1;

%% run analysis
flag_run = true;
flag_tune = false;
flag_bootstrap = true;

%% tune parameters
% flag_run = false;
% flag_tune = true;

%% run variations
pdc_analysis_variations(params,...
    'flag_run',flag_run,...
    'flag_tune',flag_tune,...
    'flag_bootstrap',flag_bootstrap);