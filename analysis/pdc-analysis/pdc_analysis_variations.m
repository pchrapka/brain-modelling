%% pdc_analysis_variations

params = [];
k=1;

% params(k).patch_type = 'aal';
% params(k).metric = 'euc';
% k = k+1;

params(k).patch_type = 'aal';
params(k).metric = 'diag';
k = k+1;

params(k).patch_type = 'aal';
params(k).metric = 'info';
k = k+1;

params(k).patch_type = 'aal-coarse-13';
params(k).metric = 'euc';
k = k+1;

params(k).patch_type = 'aal-coarse-13';
params(k).metric = 'diag';
k = k+1;

params(k).patch_type = 'aal-coarse-13';
params(k).metric = 'info';
k = k+1;

for i=1:length(params)
    
    pdc_analysis_main(params(i).metric,params(i).patch_type);
end