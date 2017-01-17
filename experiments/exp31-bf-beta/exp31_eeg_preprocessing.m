%% exp31_eeg_preprocessing

%% options

save_files = false;
interactive = false;

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

%% data file
[data_file,data_name,elec_file] = get_data_andrew(subject_num,deviant_percent);

dataset = data_file;
dataset_name = [stimulus '-' data_name(1:3)];

outdir = fullfile(script_dir,'output',dataset_name);

params = {...
    'recompute', false,...
    'save', true,...
    'overwrite', true,...
    'outpath', outdir,...
    };

%%%%%%%%%%%%%%%%%%%%%%%%%
%% de-artifact

%% ft_preprocessing

cfg_pp = [];
%cfg_pp.method = 'trial';
cfg_pp.dataset = dataset;   % needs dataset field in this case
cfg_pp.continuous = 'yes';
cfg_pp.detrend = 'no';
cfg_pp.demean = 'no';       % filter should handle this
cfg_pp.baselinewindow = [-0.1 0];
cfg_pp.channel = {'EEG','-D32','-C10'};
cfg_pp.bpfilter = 'yes';
cfg_pp.bpfreq = [1 60];
cfg_pp.bpfilttype = 'but';
cfg_pp.bpfiltord = 3;
%use default for other bp filter params

file_art_pp = run_ft_function('ft_preprocessing',cfg_pp,params{:},'tag','art');

% % preprocess data
% data_preprocessed_art1 = ft_preprocessing(cfg_pp);

if interactive
    data = ftb.util.loadvar(file_art_pp);
    ft_databrowser([],data);
    clear data;
end

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
cfg_dt.trialdef.prestim = 0.5; % in seconds
cfg_dt.trialdef.poststim = 1; % in seconds

file_art_dt = run_ft_function('ft_definetrial',cfg_dt,params{:},'tag','art');

% define the trial
% data_definetrial = ft_definetrial(cfg_dt);

cfg_rt = ftb.util.loadvar(file_art_dt);
file_art_rt = run_ft_function('ft_redefinetrial',cfg_rt,file_art_pp,params{:},'tag','art');

% data_redefined_art = ft_redefinetrial(data_definetrial, data_preprocessed_art);

% if save_files
%     save_tag(data_redefined_art, 'tag', 'ft_redefinetrial_art', 'overwrite', true, 'outpath', outdir);
% end
% 
% clear data_preprocessed_art

%% ft_artifact_threshold
% reject trials that exceed 140 uV
cfg_at = [];
cfg_at.trl = data_definetrial.trl;
cfg_at.continuous = 'no';
cfg_at.artfctdef.threshold.bpfilter = 'no';
threshold = 40;
cfg_at.artfctdef.threshold.min = -1*threshold;
cfg_at.artfctdef.threshold.max = threshold;

file_art_at = run_ft_function('ft_artifact_threshold',cfg_at,file_art_rt,params{:},'tag','art','dataidx',2);

% [~,data_artifact] = ft_artifact_threshold(cfg_at, data_redefined_art);

%%%%%%%%%%%%%%%%%%%%%%%%%
%% preprocess

%% ft_preprocessing

cfg_pp = [];
%cfg_pp.method = 'trial';
cfg_pp.dataset = dataset;   % needs dataset field in this case
cfg_pp.continuous = 'yes';
cfg_pp.detrend = 'no';
cfg_pp.demean = 'no';       % filter should handle this
cfg_pp.channel = {'EEG','-D32','-C10'};
cfg_pp.bpfilter = 'yes';
cfg_pp.bpfreq = [15 25];
cfg_pp.bpfilttype = 'but';
cfg_pp.bpfiltord = 4; % use default
%use default for other bp filter params

file_pp = run_ft_function('ft_preprocessing',cfg_pp,params{:});

% % preprocess data
% data_preprocessed = ft_preprocessing(cfg_pp);
% 
% if save_files
%     save_tag(data_preprocessed, 'tag', 'ft_preprocessing', 'overwrite', true, 'outpath', outdir);
% end

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
cfg_dt.trialdef.prestim = 0.5; % in seconds
cfg_dt.trialdef.poststim = 1; % in seconds


% define the trial
% data_definetrial = ft_definetrial(cfg_dt);

file_dt = run_ft_function('ft_definetrial',cfg_dt,params{:});

% data_redefined = ft_redefinetrial(data_definetrial, data_preprocessed);

cfg_rt = ftb.util.loadvar(file_art_dt);
file_rt = run_ft_function('ft_redefinetrial',cfg_rt,file_pp,params{:});

% if save_files
%     save_tag(data_redefined, 'tag', 'ft_redefinetrial', 'overwrite', true, 'outpath', outdir);
% end

%% ft_rejectartifact
cfg_ra = [];
cfg_ra.artfctdef.reject = 'complete';
cfg_ra.artfctdef.threshold = data_artifact;

% data_rejectartifact = ft_rejectartifact(cfg_ra, data_redefined);

file_ra = run_ft_function('ft_rejectartifact',cfg_ra,file_rt,params{:});

% if save_files
% save_tag(data_rejectartifact, 'tag', 'ft_rejectartifact', 'overwrite', true, 'outpath', outdir);
% end

%% ft_timelock

cfg_tl = [];
cfg_tl.covariance = 'yes';
cfg_tl.covariancewindow = 'all'; % should be default
cfg_tl.keeptrials = 'yes'; % should be default
cfg_tl.removemean = 'yes';

% data_timelock = ft_timelockanalysis(cfg_tl,data_rejectartifact);
file_tl = run_ft_function('ft_timelockanalysis',cfg_tl,file_ra,params{:});

% if save_files
% save_tag(data_timelock, 'tag', 'ft_timelockanalysis', 'overwrite', true, 'outpath', outdir);
% end