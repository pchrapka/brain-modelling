%% pdc_analysis_variations

patch_types = {'aal','aal-coarse-13'};
metrics = {'euc','diag','info'};

for j=1:length(patch_types)
    patch_type = patch_types{j};
    for i=1:length(metrics)
        metric = metrics{i};
        pdc_analysis_main(metric,patch_type);
    end
end