function eeg_preprocessing_andrew(subject, deviant_percent, stimulus, varargin)
%EEG_PREPROCESSING_ANDREW preprocesses EEG data according to Andrew's method
%   EEG_PREPROCESSING_ANDREW(subject, deviant_percent, stimulus) preprocesses EEG
%   data according to Andrew's method
%
%   Input
%   -----
%   subject (integer)
%       subject number, ranges from 1-10
%   deviant_percent (integer)
%       percentage of deviant trials 10 or 20
%   stimulus (string)
%       stimulus type, can be std or odd
%
%   Parameters
%   ----------
%   outdir (string, default = pwd)
%       output directory
%   patches (string, default = 'aal')
%       patch model, can be aal or aal-coarse-13

p = inputParser();
addRequired(p,'subject',@isnumeric);
addRequired(p,'deviant_percent',@(x) isequal(x,10) || isequal(x,20));
addRequired(p,'stimulus',@(x) any(validatestring(x,{'std','odd'})));
addParameter(p,'patches','aal',@(x) any(validatestring(x,{'aal','aal-coarse-13'})));
addParameter(p,'outdir','',@ischar);
parse(p,subject, deviant_percent, stimulus, varargin{:});

if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

%% options

interactive = false;

params = {...
    'recompute', false,...
    'save', true,...
    'overwrite', true,...
    'outpath', outdir,...
    };

%% get data

[dataset,~,~] = get_data_andrew(subject,deviant_percent);

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
switch subject
    case 6
        cfg_pp.channel = {'EEG','-D32','-C10'};
    otherwise
        cfg_pp.channel = {'EEG'};
end
cfg_pp.bpfilter = 'yes';
cfg_pp.bpfreq = [1 60];
cfg_pp.bpfilttype = 'but';
cfg_pp.bpfiltord = 3;
%use default for other bp filter params

file_art_pp = fthelpers.run_ft_function('ft_preprocessing',cfg_pp,params{:},'tag','art');

if interactive
    data = loadfile(file_art_pp);
    ft_databrowser([],data);
    clear data;
end

%% ft_definetrial
cfg_dt = [];
cfg_dt.dataset = dataset;
% use default function
switch stimulus
    case 'std'
        cfg_dt.trialfun= 'fthelpers.ft_trialfun_triplet';
        cfg_dt.trialmid.eventtype = 'STATUS';
        cfg_dt.trialmid.eventvalue = 1; % standard
        cfg_dt.trialpre.eventtype = 'STATUS';
        cfg_dt.trialpre.eventvalue = 1; % standard
        cfg_dt.trialpost.eventtype = 'STATUS';
        cfg_dt.trialpost.eventvalue = 1; % standard
        
        cfg_dt.trialmid.prestim = 0.5; % in seconds
        cfg_dt.trialmid.poststim = 1; % in seconds
    case 'odd'
        cfg_dt.trialdef.eventtype = 'STATUS';
        cfg_dt.trialdef.eventvalue = {2}; % deviant
        cfg_dt.trialdef.prestim = 0.5; % in seconds
        cfg_dt.trialdef.poststim = 1; % in seconds
end

% define the trial
file_art_dt = fthelpers.run_ft_function('ft_definetrial',cfg_dt,params{:},'tag','art');

cfg_rt = loadfile(file_art_dt);
file_art_rt = fthelpers.run_ft_function('ft_redefinetrial',cfg_rt,'datain',file_art_pp,params{:},'tag','art');
clear cfg_rt;

%% ft_preprocessing

cfg_pp = [];
cfg_pp.demean = 'yes';
cfg_pp.baselinewindow = [-0.1 0];

file_art_pp2 = fthelpers.run_ft_function('ft_preprocessing',cfg_pp,params{:},'datain',file_art_rt,'tag','2-art');


%% ft_artifact_threshold
% reject trials that exceed 140 uV
data_dt = loadfile(file_art_dt);
cfg_at = [];
cfg_at.trl = data_dt.trl;
clear data_dt
cfg_at.continuous = 'no';
cfg_at.artfctdef.threshold.bpfilter = 'no';
threshold = 60;
cfg_at.artfctdef.threshold.min = -1*threshold;
cfg_at.artfctdef.threshold.max = threshold;

file_art_at = fthelpers.run_ft_function('ft_artifact_threshold',cfg_at,'datain',file_art_pp2,params{:},'tag','art');
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
switch subject
    case 6
        cfg_pp.channel = {'EEG','-D32','-C10'};
    otherwise
        cfg_pp.channel = {'EEG'};
end
cfg_pp.bpfilter = 'yes';
cfg_pp.bpfreq = [15 25];
cfg_pp.bpfilttype = 'but';
cfg_pp.bpfiltord = 4; % use default
%use default for other bp filter params

file_pp = fthelpers.run_ft_function('ft_preprocessing',cfg_pp,params{:});

%% ft_definetrial
cfg_dt = [];
cfg_dt.dataset = dataset;
% use default function
switch stimulus
    case 'std'
        cfg_dt.trialfun= 'fthelpers.ft_trialfun_triplet';
        cfg_dt.trialmid.eventtype = 'STATUS';
        cfg_dt.trialmid.eventvalue = 1; % standard
        cfg_dt.trialpre.eventtype = 'STATUS';
        cfg_dt.trialpre.eventvalue = 1; % standard
        cfg_dt.trialpost.eventtype = 'STATUS';
        cfg_dt.trialpost.eventvalue = 1; % standard
        
        cfg_dt.trialmid.prestim = 0.5; % in seconds
        cfg_dt.trialmid.poststim = 1; % in seconds
    case 'odd'
        cfg_dt.trialdef.eventtype = 'STATUS';
        cfg_dt.trialdef.eventvalue = {2}; % deviant
        cfg_dt.trialdef.prestim = 0.5; % in seconds
        cfg_dt.trialdef.poststim = 1; % in seconds
end

file_dt = fthelpers.run_ft_function('ft_definetrial',cfg_dt,params{:});

cfg_rt = loadfile(file_dt);
file_rt = fthelpers.run_ft_function('ft_redefinetrial',cfg_rt,'datain',file_pp,params{:});
clear cfg_rt

%% ft_rejectartifact
cfg_ra = [];
cfg_ra.artfctdef.reject = 'complete';
data_artifact = loadfile(file_art_at);
cfg_ra.artfctdef.threshold.artifact = data_artifact{2};
clear data_artifact

file_ra = fthelpers.run_ft_function('ft_rejectartifact',cfg_ra,'datain',file_rt,params{:});
clear cfg_ra;

%% ft_timelock

cfg_tl = [];
cfg_tl.covariance = 'yes';
cfg_tl.covariancewindow = 'all'; % should be default
cfg_tl.keeptrials = 'yes'; % should be default
cfg_tl.removemean = 'yes';

file_tl = fthelpers.run_ft_function('ft_timelockanalysis',cfg_tl,'datain',file_ra,params{:});

end