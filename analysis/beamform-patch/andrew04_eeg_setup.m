%% andrew04_eeg_setup

[srcdir,~,~] = fileparts(mfilename('fullpath'));
data_file = fullfile(srcdir,'..','..','..','data-andrew-beta','exp04_10.bdf');

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