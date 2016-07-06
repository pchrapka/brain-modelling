%% exp23_explore_bf_pipeline
%   Goal:
%       plots timelocked eeg data as well as the difference between std and
%       odd

% clear all;
% close all;

% get analysis
% analysis = build_analysis_beamform_patch();
analysis = build_analysis_beamform_patch_consec();

% get elec layout
eobj = analysis{1}.steps{5}.get_dep('ftb.Electrodes');
cfg = [];
cfg.elecfile = eobj.elec_aligned;
layout = ft_prepare_layout(cfg);

% get data

for i=1:length(analysis)
    figure;
    analysis{i}.steps{5}.plot_data('timelock');
end

data = {};
for i=1:length(analysis)
    data{i} = loadfile(analysis{i}.steps{5}.timelock);
end

% plot data
figure;
cfgin = [];
cfgin.showlabels = 'yes';
cfgin.layout = layout;
cfgin.parameter = 'avg';
cfgin.baseline = [0 0.4];
ft_multiplotER(cfgin, data{1}, data{2});

data_diff = data{2};
data_diff = rmfield(data_diff,'trial');
data_diff = rmfield(data_diff,'cov');
data_diff.dimord = 'chan_time';
nsamples = size(data{2}.avg,2);
data{1}.avg = data{1}.avg(:,1:nsamples);
data_diff.avg = data{1}.avg - data{2}.avg;

% plot diff
figure;
cfgin = [];
cfgin.showlabels = 'yes';
cfgin.layout = layout;
ft_multiplotER(cfgin, data_diff);