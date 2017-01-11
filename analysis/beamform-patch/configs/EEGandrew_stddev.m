function params_eeg = EEGandrew_stddev(dataset, data_name, stimulus)
% EEGANDREW_STDDEV creates a subject specific config for ftb.EEG
%   EEGANDREW_STDDEV(dataset, data_name, stimulus) creates a subject
%   specific config for ftb.EEG
%
%   Input
%   -----
%   dataset (string)
%       path to data files
%   data_name (string)
%       subject prefix of eeg data file, i.e. prefix before -MMNf.eeg
%   stimulus (string)
%       type of stimulus: odd or std
%   
%   Output
%   ------
%   config_file (string)
%       file name of config

p = inputParser;
addRequired(p,'dataset',@ischar);
addRequired(p,'data_name',@ischar);
addRequired(p,'stimulus',@(x) any(validatestring(x,{'std','odd'})));
parse(p,dataset,data_name,stimulus);

params_eeg = [];
params_eeg.name = [stimulus '-' data_name(1:3)];
params_eeg.mode = 'continuous';

params_eeg.ft_definetrial = [];
params_eeg.ft_definetrial.dataset = dataset;
% use default function
switch stimulus
    case 'std'
        params_eeg.ft_definetrial.trialdef.eventtype = 'STATUS';
        params_eeg.ft_definetrial.trialdef.eventvalue = {1}; % standard
    case 'odd'
        params_eeg.ft_definetrial.trialdef.eventtype = 'STATUS';
        params_eeg.ft_definetrial.trialdef.eventvalue = {2}; % deviant
end
params_eeg.ft_definetrial.trialdef.prestim = 0.1; % in seconds
params_eeg.ft_definetrial.trialdef.poststim = 0.3; % in seconds

% assuming data was already de-artifacted
%params_eeg.ft_preprocessing.method = 'trial';
params_eeg.ft_preprocessing.dataset = dataset;
params_eeg.ft_preprocessing.continuous = 'yes';
params_eeg.ft_preprocessing.detrend = 'no';
params_eeg.ft_preprocessing.demean = 'no'; % filter should handle this
%params_eeg.ft_preprocessing.baselinewindow = [-0.2 0];
params_eeg.ft_preprocessing.channel = 'EEG';
params_eeg.ft_preprocessing.bpfilter = 'yes';
params_eeg.ft_preprocessing.bpfreq = [0.3 100];
params_eeg.ft_preprocessing.bpfilttype = 'firws';
%use default for other bp filter params

% reject trials that exceed 140 uV
params_eeg.ft_artifact_threshold.continuous = 'no';
params_eeg.ft_artifact_threshold.artfctdef.bpfilter = 'no';
params_eeg.ft_artifact_threshold.artfctdef.threshold.min = -140;
params_eeg.ft_artifact_threshold.artfctdef.threshold.max = 140;
params_eeg.ft_rejectartifact.artfctdef.reject = 'complete';

params_eeg.ft_timelockanalysis.covariance = 'yes';
params_eeg.ft_timelockanalysis.covariancewindow = 'all'; % should be default
params_eeg.ft_timelockanalysis.keeptrials = 'yes'; % should be default
params_eeg.ft_timelockanalysis.removemean = 'yes';

subject_slug = strrep(data_name,'_','');
subject_slug = strrep(subject_slug,' ','');
config_file = [strrep(mfilename,'_','-') '-' subject_slug '-' stimulus '.mat'];

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, config_file),'params_eeg');

end