% load eeg

% subject specific info
[datadir,subject_file,subject_name] = get_coma_data(20);
datafile = [subject_file '-MMNf.eeg'];

%% Check header and events
cfg = [];
cfg.dataset = fullfile(datadir,datafile);

hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

%% List events
cfg = [];
cfg.dataset = fullfile(datadir,datafile);
cfg.trialdef.eventtype = '?';
cfg = ft_definetrial(cfg);

%% Define standard response
cfg = [];
cfg.dataset = fullfile(datadir,datafile);
% use default function
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S 11'};
cfg.trialdef.prestim = 0.4; % in seconds
cfg.trialdef.poststim = 1; % in seconds
cfg_std = ft_definetrial(cfg);

%%
% assuming data was already processed
cfg_std.method = 'trial';
cfg_std.continuous = 'no';
cfg_std.detrend = 'no';
cfg_std.demean = 'no';
cfg_std.channel = 'EEG';
data_std = ft_preprocessing(cfg_std);

%% Define deviant response
cfg = [];
cfg.dataset = fullfile(datadir,datafile);
% use default function
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S 16'};
cfg.trialdef.prestim = 0.4; % in seconds
cfg.trialdef.poststim = 1; % in seconds
cfg_odd = ft_definetrial(cfg);