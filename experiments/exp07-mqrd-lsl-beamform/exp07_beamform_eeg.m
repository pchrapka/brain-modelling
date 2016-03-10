%% exp07_beamform_eeg
% Goal: 
%   Apply beamforming to real EEG data

close all;

doplot = true;

datadir = '/home/phil/projects/data-coma-richard/BC-HC-YOUTH/Cleaned';
% subject = 'BC.HC.YOUTH.P020-10834';
% subject = 'BC.HC.YOUTH.P021-10852';
subject = 'BC.HC.YOUTH.P022-9913';
subject_name = strrep(subject,'BC.HC.YOUTH.','');

subject_specific = true;
% option_elec = 'subject';
simulate_test = true;

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
if simulate_test
    % EEG - simulated
    params_dsim = 'DSdip3-sine-cm.mat';
    dsim = ftb.DipoleSim(params_dsim,'dip3-sine-cm');
    analysis.add(dsim);
    dsim.force = false;
else
    % EEG - real
    params_eeg.ft_definetrial = [];
    params_eeg.ft_definetrial.dataset = fullfile(datadir,[subject '-MMNf.eeg']);
    % use default function
    params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
    params_eeg.ft_definetrial.trialdef.eventvalue = {'S 11'}; % standard
    %params_eeg.ft_definetrial.trialdef.eventvalue = {'S 16'}; % deviant
    params_eeg.ft_definetrial.trialdef.prestim = 0.4; % in seconds
    params_eeg.ft_definetrial.trialdef.poststim = 1; % in seconds
    
    % assuming data was already processed
    params_eeg.ft_preprocessing.method = 'trial';
    params_eeg.ft_preprocessing.detrend = 'no';
    params_eeg.ft_preprocessing.demean = 'no';
    params_eeg.ft_preprocessing.baselinewindow = [-0.4 0];
    params_eeg.ft_preprocessing.channel = 'EEG';
    
    params_eeg.ft_timelockanalysis.covariance = 'yes';
    params_eeg.ft_timelockanalysis.covariancewindow = 'poststim';
    params_eeg.ft_timelockanalysis.keeptrials = 'no';
    params_eeg.ft_timelockanalysis.removemean = 'yes';
    
    eeg = ftb.EEG(params_eeg,[eeg_name 'event']);
    analysis.add(eeg);
    eeg.force = true;
end

% Beamformer
params_bf = 'BFlcmv-exp07.mat';
bf = ftb.Beamformer(params_bf,'lcmv-exp07');
analysis.add(bf);

%% Process pipeline
analysis.init();
analysis.process();

% FIXME NOT WORKING!!!

%% Plot all results
% TODO Check individual trials

if exist('dsim','var')
    figure;
    bf.plot({'brain','skull','scalp','fiducials','dipole'});
end

% figure;
% cfg = [];
% cfg.datafile = fullfile(datadir,datafile);
% cfg.continuous = 'yes';
% ft_databrowser(cfg);

% figure;
% cfg = ftb.util.loadvar(eeg.definetrial);
% ft_databrowser(cfg);

% figure;
% eeg.plot_data('preprocessed');
% 
% figure;
% eeg.plot_data('timelock');

% figure;
% bf.plot({'brain','skull','scalp','fiducials'});
figure;
bf.plot_scatter([]);
bf.plot_anatomical('method','slice');

