%% exp31_bf_explore

stimulus = 'std';
subject = 6;
deviant_percent = 10;
patches_type = 'aal';
% patches_type = 'aal-coarse-13';

[~,data_name,~] = get_data_andrew(subject,deviant_percent);

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,'patches',patches_type)); 
pipeline.process();

%%

data_name2 = sprintf('%s-%s',stimulus,data_name);
eeg = loadfile(fullfile('output',data_name2,'ft_rejectartifact.mat');

%%
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,eeg);

%%
sources = loadfile(pipeline.steps{end}.sourceanalysis);
lf = loadfile(pipeline.steps{end}.lf.leadfield);

%% convert source analysis to EEG data structure
ntrials = length(sources.trial);
data = copyfields(eeg,[],{'fsample','trialinfo','sampleinfo'});
data.label = lf.filter_label(lf.inside);
for i=1:ntrials
    data.trial{i} = cell2mat(sources.trial(i).mom(sources.inside));
    data.time{i} = sources.time;
end

%%
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,data);
