%% pdc_analysis_variations

params = [];
k=1;

%% aal
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
params(k).patch_type = 'aal-coarse-19';
params(k).metric = 'euc';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.98;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
k = k+1;

params(k).patch_type = 'aal-coarse-19';
params(k).metric = 'diag';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.98;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
k = k+1;

params(k).patch_type = 'aal-coarse-19';
params(k).metric = 'info';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.98;
params(k).gamma = 1e-3;
params(k).normalization = 'allchannels';
params(k).envelope = true;
k = k+1;

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