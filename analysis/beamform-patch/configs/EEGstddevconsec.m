function config_file = EEGstddevconsec(datadir, subject, stimulus)
% EEGSTDDEVCONSEC creates a subject specific config for ftb.EEG
%   EEGSTDDEVCONSEC(datadir, subject, stimulus) creates a subject specific
%   config for ftb.EEG. This parameter file is very similar to EEGstddev,
%   with the exception that standard trials are only selected if they
%   preceed a deviant trial.
%
%   Input
%   -----
%   datadir (string)
%       path to data files
%   subject (string)
%       subject prefix of eeg data file, i.e. prefix before -MMNf.eeg
%   stimulus (string)
%       type of stimulus: odd or std
%   
%   Output
%   ------
%   config_file (string)
%       file name of config

p = inputParser;
addRequired(p,'subject',@ischar);
addRequired(p,'stimulus',@(x) any(validatestring(x,{'std','odd'})));
parse(p,subject,stimulus);

[srcdir,~,~] = fileparts(mfilename('fullpath'));

params_eeg = [];
params_eeg.ft_definetrial = [];
params_eeg.ft_definetrial.dataset = fullfile(datadir,[subject '-MMNf.eeg']);
% use default function
switch stimulus
    case 'std'
        params_eeg.ft_definetrial.trialfun = 'ft_trialfun_preceed';
        params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
        params_eeg.ft_definetrial.trialdef.eventvalue = 'S 11'; % standard
        params_eeg.ft_definetrial.trialpost.eventtype = 'Stimulus';
        params_eeg.ft_definetrial.trialpost.eventvalue = 'S 16'; % deviant
    case 'odd'
        params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
        params_eeg.ft_definetrial.trialdef.eventvalue = {'S 16'}; % deviant
end
params_eeg.ft_definetrial.trialdef.prestim = 0.2; % in seconds
params_eeg.ft_definetrial.trialdef.poststim = 0.5; % in seconds

% assuming data was already de-artifacted
%params_eeg.ft_preprocessing.method = 'trial';
params_eeg.ft_preprocessing.continuous = 'yes';
params_eeg.ft_preprocessing.detrend = 'no';
params_eeg.ft_preprocessing.demean = 'yes';
%params_eeg.ft_preprocessing.baselinewindow = [-0.2 0];
params_eeg.ft_preprocessing.channel = 'EEG';

params_eeg.ft_timelockanalysis.covariance = 'yes';
params_eeg.ft_timelockanalysis.covariancewindow = 'all'; % should be default
params_eeg.ft_timelockanalysis.keeptrials = 'yes'; % should be default
params_eeg.ft_timelockanalysis.removemean = 'yes';

% % specify pre post times
% params_eeg.pre.ft_redefinetrial.toilim = [-0.2 0];
% params_eeg.pre.ft_timelockanalysis.covariance = 'yes';
% params_eeg.pre.ft_timelockanalysis.covariancewindow = 'all'; % should be default
% 
% params_eeg.post.ft_redefinetrial.toilim = [0 0.5];
% params_eeg.post.ft_timelockanalysis.covariance = 'yes';
% params_eeg.post.ft_timelockanalysis.covariancewindow = 'all'; % should be default

subject_slug = strrep(subject,'_','');
subject_slug = strrep(subject_slug,' ','');
config_file = [strrep(mfilename,'_','-') '-' subject_slug '-' stimulus '.mat'];
save(fullfile(srcdir, config_file),'params_eeg');

end