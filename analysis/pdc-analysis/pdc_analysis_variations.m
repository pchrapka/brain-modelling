%% pdc_analysis_variations

params = [];
k=1;

%% aal
% NOTE re tune parameters with ver 4 sparse filter
% params(k).patch_type = 'aal';
% params(k).metric = 'euc';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-4;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;
% 
% params(k).patch_type = 'aal';
% params(k).metric = 'diag';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-4;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;
% 
% params(k).patch_type = 'aal';
% params(k).metric = 'info';
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
% params(k).metric = 'euc';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-1;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19';
% params(k).metric = 'diag';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-1;
% params(k).normalization = 'allchannels';
% params(k).envelope = false;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19';
% params(k).metric = 'info';
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
% params(k).metric = 'euc';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19';
% params(k).metric = 'diag';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19';
% params(k).metric = 'info';
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
% params(k).metric = 'euc';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19-plus2';
% params(k).metric = 'diag';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19-plus2';
% params(k).metric = 'info';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.98;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;

% lots of deep activity still

%% aal-coarse-19-outer-plus
params(k).patch_type = 'aal-coarse-19-outer-plus2';
params(k).metric = 'euc';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = false;
k = k+1;

params(k).patch_type = 'aal-coarse-19-outer-plus2';
params(k).metric = 'diag';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = false;
k = k+1;

params(k).patch_type = 'aal-coarse-19-outer-plus2';
params(k).metric = 'info';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = false;
k = k+1;

%% aal-coarse-19-outer-plus2 envelope
% params(k).patch_type = 'aal-coarse-19-outer-plus2';
% params(k).metric = 'euc';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19-outer-plus2';
% params(k).metric = 'diag';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% params(k).patch_type = 'aal-coarse-19-outer-plus2';
% params(k).metric = 'info';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-3;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% k = k+1;
% 
% % looks much, prefrontal is still pretty hot and not really symmetric

for i=1:length(params)
    
    pdc_analysis_main(...
        'metric',params(i).metric,...
        'patch_type',params(i).patch_type,...
        'ntrials',params(i).ntrials,...
        'order',params(i).order,...
        'lambda',params(i).lambda,...
        'gamma',params(i).gamma,...
        'normalization',params(i).normalization,...
        'envelope',params(i).envelope);
end