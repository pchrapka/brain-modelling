%% exp23_explore_bf_pipeline

clear all;
close all;

analysis = build_analysis_beamform_patch();

for i=1:length(analysis)
    figure;
    analysis{i}.steps{5}.plot_data('timelock');
end

data = {};
for i=1:length(analysis)
    data{i} = ftb.util.loadvar(analysis{i}.steps{5}.timelock);
end

data_diff = data{1};
data_diff.avg = data{1}.avg - data{2}.avg;

eobj = analysis{1}.steps{5}.get_dep('ftb.Electrodes');
cfg = [];
cfg.elecfile = eobj.elec_aligned;
layout = ft_prepare_layout(cfg);

figure;
cfgin = [];
cfgin.showlabels = 'yes';
cfgin.layout = layout;
ft_multiplotER(cfgin, data_diff);