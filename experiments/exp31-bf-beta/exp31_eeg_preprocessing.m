
%% options

save_files = true;

subject_num = 6;
deviant_percent = 10;
stimulus = 'std';
% stimulus = 'odd';

script_name = mfilename('fullpath');
if isempty(script_name)
    [~,work_dir,~] = fileparts(pwd);
    if isequal(work_dir,'exp31-bf-beta')
        script_dir = pwd;
    else
        error('cd to exp31-bf-beta');
    end
else
    [script_dir,~,~] = fileparts([script_name '.m']);
end
outdir = fullfile(script_dir,'output');

%% data file
[data_file,data_name,elec_file] = get_data_andrew(subject_num,deviant_percent);

dataset = data_file;
dataset_name = [stimulus '-' data_name(1:3)];

%% ft_preprocessing

cfg_pp = [];
%cfg_pp.method = 'trial';
cfg_pp.dataset = dataset;   % needs dataset field in this case
cfg_pp.continuous = 'yes';
cfg_pp.detrend = 'no';
cfg_pp.demean = 'no';       % filter should handle this
%cfg_pp.baselinewindow = [-0.2 0];
cfg_pp.channel = 'EEG';
cfg_pp.bpfilter = 'yes';
cfg_pp.bpfreq = [0.3 100];
cfg_pp.bpfilttype = 'firws';
%use default for other bp filter params

% preprocess data
data_preprocessed1 = ft_preprocessing(cfg_pp);

if save_files
    save_tag(data_preprocessed1, 'tag', 'ft_preprocessing1', 'overwrite', true, 'outpath', outdir);
end

ft_databrowser([],data_preprocessed1);

 
%% ft_preprocessing 2
cfg_pp2 = [];
cfg_pp2.channel = {'all','-D32','-C10'};
data_preprocessed2 = ft_preprocessing(cfg_pp2, data_preprocessed1);

ft_databrowser([],data_preprocessed2);

if save_files
    save_tag(data_preprocessed2, 'tag', 'ft_preprocessing2', 'overwrite', true, 'outpath', outdir);
end

clear data_preprocessed1
data_preprocessed = data_preprocessed2;
clear data_preprocessed2

%% ft_definetrial
cfg_dt = [];
cfg_dt.dataset = dataset;
% use default function
switch stimulus
    case 'std'
        cfg_dt.trialdef.eventtype = 'STATUS';
        cfg_dt.trialdef.eventvalue = {1}; % standard
    case 'odd'
        cfg_dt.trialdef.eventtype = 'STATUS';
        cfg_dt.trialdef.eventvalue = {2}; % deviant
end
cfg_dt.trialdef.prestim = 0.1; % in seconds
cfg_dt.trialdef.poststim = 0.3; % in seconds


% define the trial
data_definetrial = ft_definetrial(cfg_dt);

data_redefined = ft_redefinetrial(data_definetrial, data_preprocessed);

if save_files
    save_tag(data_redefined, 'tag', 'ft_redefinetrial', 'overwrite', true, 'outpath', outdir);
end

%% ft_artifact_threshold
% reject trials that exceed 140 uV
cfg_at = [];
cfg_at.trl = data_definetrial.trl;
cfg_at.continuous = 'no';
cfg_at.artfctdef.threshold.bpfilter = 'no';
cfg_at.artfctdef.threshold.min = -140;
cfg_at.artfctdef.threshold.max = 140;

[~,data_artifact] = ft_artifact_threshold(cfg_at, data_redefined);

cfg_ra = [];
cfg_ra.artfctdef.reject = 'complete';
cfg_ra.artfctdef.threshold = data_artifact;

data_rejectartifact = ft_rejectartifact(cfg_ra, data_redefined);

if save_files
    save_tag(data_rejectartifact, 'tag', 'ft_rejectartifact', 'overwrite', true, 'outpath', outdir);
end

%% ft_timelock

cfg_tl = [];
cfg_tl.covariance = 'yes';
cfg_tl.covariancewindow = 'all'; % should be default
cfg_tl.keeptrials = 'yes'; % should be default
cfg_tl.removemean = 'yes';

data_timelock = ft_timelockanalysis(cfg_tl,data_rejectartifact);

if save_files
    save_tag(data_timelock, 'tag', 'ft_timelockanalysis', 'overwrite', true, 'outpath', outdir);
end