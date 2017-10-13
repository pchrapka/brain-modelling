%% exp31_bf_explore

stimulus = 'std';
subject = 6;
deviant_percent = 10;
patch_options = {...
    'patchmodel','aal',...
    'patchoptions',{}};
% patch_options = {...
%     'patchmodel','aal-coarse-13',...
%     'patchoptions',{}};

[~,data_name,~] = get_data_andrew(subject,deviant_percent);

pipeline = build_pipeline_beamformerpatch(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,patch_options{:})); 
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

%% compute phase-locked avg
avg = zeros(size(data.trial{1}));
for i=1:ntrials
    avg = avg + data.trial{i};
end
avg = avg/ntrials;

data_phaselocked = copyfields(data,[],{'fsamples','label'});
data_phaselocked.trial{1} = avg;
data_phaselocked.time{1} = data.time{1};
data_phaselocked.trialinfo = data.trialinfo(1);
data_phaselocked.sampleinfo = data.sampleinfo(1,:);

%%
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,data_phaselocked);

%% compute induced response
data_induced = data;
for i=1:ntrials
    data_induced.trial{i} = data.trial{i} - avg;
end

%%
cfg = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg,data_induced);

