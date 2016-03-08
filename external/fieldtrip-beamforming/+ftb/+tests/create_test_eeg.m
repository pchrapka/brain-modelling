function obj = create_test_eeg()

cfg = [];
cfg.ft_definetrial = [];
% TODO Add real data?
%cfg.ft_definetrial.dataset = ;
%cfg.ft_definetrial.trialdef.eventtype = 'Stimulus';
%cfg.ft_definetrial.trialdef.eventvalue = {'S 11'};
%cfg.ft_definetrial.trialdef.prestim = 0.4; % in seconds
%cfg.ft_definetrial.trialdef.poststim = 1; % in seconds

cfg.ft_preprocessing = [];
cfg.ft_preprocessing.method = 'trial';
cfg.ft_preprocessing.continuous = 'no';
cfg.ft_preprocessing.detrend = 'no';
cfg.ft_preprocessing.demean = 'no';
cfg.ft_preprocessing.channel = 'EEG';

obj = ftb.EEG(cfg, 'TestEEG');

end