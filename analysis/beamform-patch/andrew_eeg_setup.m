%% andrew_eeg_setup

[data_file,~,~] = get_data_andrew(4,10);

%% Check header and events
cfg = [];
cfg.dataset = data_file;

hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

%% List events
cfg = [];
cfg.dataset = data_file;
cfg.trialdef.eventtype = '?';
cfg = ft_definetrial(cfg);

%% check single trial stuff

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(6,10,'std'));

eeg_obj = pipeline.steps{end}.get_dep('ftb.EEG');

%%
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = 'all';
cfg.keeptrials = 'no';
cfg.removemean = 'yes';

data_pre = loadfile(eeg_obj.preprocessed);
timelock = ft_timelockanalysis(cfg,data_pre);

%%
lf_obj = pipeline.steps{end}.get_dep('ftb.Leadfield');
grid = loadfile(lf_obj.leadfield);

cfg = [];
cfg.method = 'lcmv';
cfg.grid = grid;
source = ft_sourceanalysis(cfg,timelock);