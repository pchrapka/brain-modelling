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
% k = k+1;
% 
% params(k).patch_type = 'aal';
% params(k).metric = 'diag';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-4;
% k = k+1;
% 
% params(k).patch_type = 'aal';
% params(k).metric = 'info';
% params(k).ntrials = 20;
% params(k).order = 3;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-4;
% k = k+1;


%% aal-coarse-13
params(k).patch_type = 'aal-coarse-13';
params(k).metric = 'euc';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-4;
k = k+1;

params(k).patch_type = 'aal-coarse-13';
params(k).metric = 'diag';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-4;
k = k+1;

params(k).patch_type = 'aal-coarse-13';
params(k).metric = 'info';
params(k).ntrials = 20;
params(k).order = 3;
params(k).lambda = 0.99;
params(k).gamma = 1e-4;
k = k+1;

for i=1:length(params)
    
    pdc_analysis_main(...
        'metric',params(i).metric,...
        'patch_type',params(i).patch_type,...
        'ntrials',params(i).ntrials,...
        'order',params(i).order,...
        'lambda',params(i).lambda,...
        'gamma',params(i).gamma);
end