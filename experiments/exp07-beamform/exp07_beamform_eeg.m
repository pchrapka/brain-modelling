%% exp07_beamform_eeg
% Goal: 
%   Apply beamforming to real EEG data

close all;

doplot = true;

% subject specific info
[datadir,subject_file,subject_name] = get_coma_data(22);

% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

%% Set up beamformer analysis
% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-common','fb');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

analysis = ftb.AnalysisBeamformer(out_folder);

%% Create and process MRI and HM

% MRI
params_mri = 'MRIS01.mat';
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = 'HMdipoli-cm.mat';
hm = ftb.Headmodel(params_hm,'dipoli-cm');

% Add steps
analysis.add(m);
analysis.add(hm);

% Process pipeline
analysis.init();
analysis.process();

%% Create and process the electrodes

% Electrodes
params_e = [];
params_e.elec_orig = fullfile(datadir,[subject '.sfp']);
e = ftb.Electrodes(params_e,subject_name);
e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
analysis.add(e);
e.force = false;

% Process pipeline
analysis.init();
analysis.process();
e.force = false;

% Manually rename channel
elec = ftb.util.loadvar(e.elec_aligned);
idx = cellfun(@(x) isequal(x,'Afz'),elec.label);
if any(idx)
    elec.label{idx} = 'AFz';
    save(e.elec_aligned,'elec');
end

e.plot({'scalp','fiducials','electrodes-aligned','electrodes-labels'});


%% Create the rest of the pipeline

% Create custom configs
% DSarind_cm();
BFlcmv_exp07();
L05cm_norm();

% Leadfield
% params_lf = 'L1cm.mat';
% lf = ftb.Leadfield(params_lf,'1cm');
params_lf = 'L1cm-norm.mat';
lf = ftb.Leadfield(params_lf,'1cm-norm');
% params_lf = 'L05cm-norm.mat';
% lf = ftb.Leadfield(params_lf,'05cm-norm');
analysis.add(lf);
lf.force = true;

% EEG
eeg_name = '';

params_eeg.ft_definetrial = [];
params_eeg.ft_definetrial.dataset = fullfile(datadir,[subject '-MMNf.eeg']);
% use default function
params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
params_eeg.ft_definetrial.trialdef.eventvalue = {'S 11'}; % standard
%params_eeg.ft_definetrial.trialdef.eventvalue = {'S 16'}; % deviant
params_eeg.ft_definetrial.trialdef.prestim = 0.2; % in seconds
params_eeg.ft_definetrial.trialdef.poststim = 0.5; % in seconds

% assuming data was already processed
params_eeg.ft_preprocessing.method = 'trial';
params_eeg.ft_preprocessing.detrend = 'no';
params_eeg.ft_preprocessing.demean = 'no';
params_eeg.ft_preprocessing.baselinewindow = [-0.2 0];
params_eeg.ft_preprocessing.channel = 'EEG';

params_eeg.ft_timelockanalysis.covariance = 'yes';
params_eeg.ft_timelockanalysis.covariancewindow = 'poststim';
params_eeg.ft_timelockanalysis.keeptrials = 'no';
params_eeg.ft_timelockanalysis.removemean = 'yes';

eeg = ftb.EEG(params_eeg,[eeg_name 'event']);
analysis.add(eeg);
eeg.force = false;

% Beamformer
params_bf = 'BFlcmv-exp07.mat';
bf = ftb.Beamformer(params_bf,'lcmv-exp07');
analysis.add(bf);
bf.force = true;

%% Process pipeline
analysis.init();
analysis.process();

% FIXME NOT WORKING!!!

%% Plot all results
% TODO Check individual trials
bf.remove_outlier(10);

% figure;
% cfg = [];
% cfg.datafile = fullfile(datadir,datafile);
% cfg.continuous = 'yes';
% ft_databrowser(cfg);

% figure;
% cfg = ftb.util.loadvar(eeg.definetrial);
% ft_databrowser(cfg);

% eegObj = eeg;
% if isa(eegObj,'ftb.EEGMMN')
%     figure;
%     eegObj.plot_data('timelock');
% else
%     figure;
%     eegObj.plot_data('preprocessed');
%     figure;
%     eegObj.plot_data('timelock');
% end

% figure;
% bf.plot({'brain','skull','scalp','fiducials'});
figure;
bf.plot_scatter([]);
bf.plot_anatomical('method','slice');
%bf.plot_anatomical('method','ortho');

figure;
bf.plot_moment('2d-all');
figure;
bf.plot_moment('2d-top');
figure;
bf.plot_moment('1d-top');
