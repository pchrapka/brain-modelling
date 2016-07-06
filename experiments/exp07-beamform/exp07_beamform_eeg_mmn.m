%% exp07_beamform_eeg_mmn
% Goal: 
%   Beamform MMN signal

close all;

doplot = true;

% subject specific info
[datadir,subject_file,subject_name] = get_coma_data(22);

subject_specific = true;
% option_elec = 'subject';

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
if subject_specific
    params_e.elec_orig = fullfile(datadir,[subject_file '.sfp']);
else
    % Not sure what cap to use easycap-M1 has right channel names but
    % too many
    error('fix me');
end

e = ftb.Electrodes(params_e,subject_name);
e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
analysis.add(e);
e.force = false;

% Process pipeline
analysis.init();
analysis.process();
e.force = false;

% Manually rename channel
% NOTE This is why the electrodes are processed ahead of time
elec = loadfile(e.elec_aligned);
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

% Leadfield
params_lf = 'L1cm-norm.mat';
lf = ftb.Leadfield(params_lf,'1cm-norm');
analysis.add(lf);
lf.force = false;

% EEG
if subject_specific
    % Electrode already has subject identifier
    eeg_name = '';
else
    % Subject identifer has not been used
    eeg_name = subject_name;
end

% EEG Deviant
params_eeg.ft_definetrial = [];
params_eeg.ft_definetrial.dataset = fullfile(datadir,[subject_file '-MMNf.eeg']);
% use default function
params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
params_eeg.ft_definetrial.trialdef.eventvalue = {'S 16'}; % deviant
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

eeg_dev = ftb.EEG(params_eeg,[eeg_name 'dev']);
analysis.add(eeg_dev);
eeg_dev.force = true;

% EEG Standard
% use the same params from deviant case
params_eeg.ft_definetrial.trialdef.eventvalue = {'S 11'}; % standard
eeg_std = ftb.EEG(params_eeg,[eeg_name 'std']);
analysis.add(eeg_std);
eeg_std.force = false;

params_eeg_mmn = [];
params_eeg_mmn.ft_timelockanalysis.covariance = 'yes';
params_eeg_mmn.ft_timelockanalysis.covariancewindow = 'poststim';
params_eeg_mmn.ft_timelockanalysis.keeptrials = 'no';
params_eeg_mmn.ft_timelockanalysis.removemean = 'yes';
eeg_mmn = ftb.EEGMMN(params_eeg_mmn,[eeg_name 'post']);
analysis.add(eeg_mmn);
eeg_mmn.force = false;

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
bf.remove_outlier(3);

% figure;
% cfg = [];
% cfg.datafile = fullfile(datadir,datafile);
% cfg.continuous = 'yes';
% ft_databrowser(cfg);

% figure;
% cfg = loadfile(eeg_std.definetrial);
% ft_databrowser(cfg);

eegObj = eeg_dev;
if isa(eegObj,'ftb.EEGMMN')
    figure;
    eegObj.plot_data('timelock');
else
    figure;
    eegObj.plot_data('preprocessed');
    figure;
    eegObj.plot_data('timelock');
end

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
