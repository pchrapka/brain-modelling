%% exp07_beamform_eeg_std_prestim_subtract
% Goal: 
%   Beamform EEG, Standard stimulus with prestimulus subtracted

close all;

doplot = true;

datadir = '/home/phil/projects/data-coma-richard/BC-HC-YOUTH/Cleaned';
% subject = 'BC.HC.YOUTH.P020-10834';
% subject = 'BC.HC.YOUTH.P021-10852';
subject = 'BC.HC.YOUTH.P022-9913';
subject_name = strrep(subject,'BC.HC.YOUTH.','');

subject_specific = true;
% option_elec = 'subject';

% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

%% Set up beamformer analysis
% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-fb');
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
    params_e.elec_orig = fullfile(datadir,[subject '.sfp']);
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

% EEG Standard
params_eeg.ft_definetrial = [];
params_eeg.ft_definetrial.dataset = fullfile(datadir,[subject '-MMNf.eeg']);
% use default function
params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
params_eeg.ft_definetrial.trialdef.eventvalue = {'S 11'}; % standard
params_eeg.ft_definetrial.trialdef.prestim = 0.4; % in seconds
params_eeg.ft_definetrial.trialdef.poststim = 1; % in seconds

% assuming data was already processed
params_eeg.ft_preprocessing.method = 'trial';
params_eeg.ft_preprocessing.detrend = 'no';
params_eeg.ft_preprocessing.demean = 'no';
params_eeg.ft_preprocessing.baselinewindow = [-0.4 0];
params_eeg.ft_preprocessing.channel = 'EEG';

params_eeg.ft_timelockanalysis.covariance = 'yes';
params_eeg.ft_timelockanalysis.covariancewindow = 'prestim';
params_eeg.ft_timelockanalysis.keeptrials = 'no';
params_eeg.ft_timelockanalysis.removemean = 'yes';

eeg_prestim = ftb.EEG(params_eeg,[eeg_name 'pre']);
analysis.add(eeg_prestim);
eeg_prestim.force = false;

% Beamformer
params_bf = 'BFlcmv-exp07.mat';
bf_prestim = ftb.Beamformer(params_bf,'pre');
analysis.add(bf_prestim);

% EEG Standard
% same params as previously
params_eeg.ft_timelockanalysis.covariancewindow = 'poststim';
eeg_poststim = ftb.EEG(params_eeg,[eeg_name 'post']);
analysis.add(eeg_poststim);
eeg_poststim.force = false;

% Beamformer
% same beamformer
bf_poststim = ftb.Beamformer(params_bf,'post');
analysis.add(bf_poststim);

% Subtract: Post - Pre
bf_sub = ftb.BeamformerSubtract(params_bf,'');
analysis.add(bf_sub);
bf_sub.force = true;

%% Process pipeline
analysis.init();
analysis.process();

% FIXME NOT WORKING!!!

%% Plot all results
% TODO Check individual trials

% figure;
% cfg = [];
% cfg.datafile = fullfile(datadir,datafile);
% cfg.continuous = 'yes';
% ft_databrowser(cfg);

% figure;
% cfg = ftb.util.loadvar(eeg_std.definetrial);
% ft_databrowser(cfg);

% figure;
% eeg_std.plot_data('preprocessed');
% 
% figure;
% eeg_std.plot_data('timelock');

% figure;
% bf.plot({'brain','skull','scalp','fiducials'});
figure;
bf_sub.plot_scatter([]);
bf_prestim.plot_anatomical('method','slice');
bf_poststim.plot_anatomical('method','slice');
bf_sub.plot_anatomical('method','slice');