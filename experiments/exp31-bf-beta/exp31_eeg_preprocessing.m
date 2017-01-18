%% exp31_eeg_preprocessing

%% options

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
% cfg_pp.baselinewindow = [-0.1 0];
cfg_pp.channel = {'EEG','-D32','-C10'};
cfg_pp.bpfilter = 'yes';
cfg_pp.bpfreq = [1 60];
cfg_pp.bpfilttype = 'but';
cfg_pp.bpfiltord = 3;
%use default for other bp filter params

file_art_pp = run_ft_function('ft_preprocessing',cfg_pp,params{:},'tag','art');

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

% define the trial
file_art_dt = run_ft_function('ft_definetrial',cfg_dt,params{:},'tag','art');

cfg_rt = ftb.util.loadvar(file_art_dt);
file_art_rt = run_ft_function('ft_redefinetrial',cfg_rt,'datain',file_art_pp,params{:},'tag','art');
clear cfg_rt;

%% ft_preprocessing

cfg_pp = [];
cfg_pp.demean = 'yes';
cfg_pp.baselinewindow = [-0.1 0];

file_art_pp2 = run_ft_function('ft_preprocessing',cfg_pp,params{:},'datain',file_art_rt,'tag','2-art');


%% ft_artifact_threshold
% reject trials that exceed 140 uV
data_dt = ftb.util.loadvar(file_art_dt);
cfg_at = [];
cfg_at.trl = data_dt.trl;
clear data_dt
cfg_at.continuous = 'no';
cfg_at.artfctdef.threshold.bpfilter = 'no';
threshold = 60;
cfg_at.artfctdef.threshold.min = -1*threshold;
cfg_at.artfctdef.threshold.max = threshold;

file_art_at = run_ft_function('ft_artifact_threshold',cfg_at,'datain',file_art_pp2,params{:},'tag','art');
clear cfg_at

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

file_dt = run_ft_function('ft_definetrial',cfg_dt,params{:});

cfg_rt = ftb.util.loadvar(file_dt);
file_rt = run_ft_function('ft_redefinetrial',cfg_rt,'datain',file_pp,params{:});
clear cfg_rt

%% ft_rejectartifact
cfg_ra = [];
cfg_ra.artfctdef.reject = 'complete';
data_artifact = ftb.util.loadvar(file_art_at);
cfg_ra.artfctdef.threshold.artifact = data_artifact{2};
clear data_artifact

file_ra = run_ft_function('ft_rejectartifact',cfg_ra,'datain',file_rt,params{:});
clear cfg_ra;

%% ft_timelock

cfg_tl = [];
cfg_tl.covariance = 'yes';
cfg_tl.covariancewindow = 'all'; % should be default
cfg_tl.keeptrials = 'yes'; % should be default
cfg_tl.removemean = 'yes';

file_tl = run_ft_function('ft_timelockanalysis',cfg_tl,'datain',file_ra,params{:});

%% compute lambda for regularization

% data_timelock = ftb.util.loadvar(file_tl);
% % average the single-trial covariance matrices
% cov_avg = squeeze(mean(data_timelock.cov,1));
% 
% ratio = 1;
% percent = ratio/100;
% lambda = percent * trace(cov_avg)/size(cov_avg,1);
% fprintf('regularization for %0.2f%%: %g\n',percent,lambda);
% clear data_timelock;
