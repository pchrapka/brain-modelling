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