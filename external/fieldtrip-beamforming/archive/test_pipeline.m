debug = false;
stage = [];

% restart_stage = 'L5mm';
% restart_stage = 'L10mm';
% restart_stage = 'Lliny10mm';
% restart_stage = 'SM1snr0';
% restart_stage = 'SS1snr0';
% restart_stage = 'SN1';
% ftb.clean_data(restart_stage);

%% Stage 1
% Create a bemcp head model
headmodel = 'HMbemcp';
% Create an openmeeg head model
% headmodel = 'HMopenmeeg';
% Most accurate according to: https://hal.inria.fr/hal-00776674/document

stage.headmodel = headmodel;
% Get the config
cfg = ftb.prepare_headmodel(stage);
% Create the model
cfg = ftb.create_headmodel(cfg);

%% Stage 2
% Create aligned electrodes
electrodes = 'E256';
stage.electrodes = electrodes;
% Get the config
cfg = ftb.prepare_electrodes(stage);
% Create the model
cfg = ftb.create_electrodes(cfg);

%% Stage 3
% Create leadfield
% leadfield = 'L1mm';
% leadfield = 'L1cm';
leadfield = 'L5mm';
% leadfield = 'L10mm';
% leadfield = 'Llinx10mm';
% leadfield = 'Lliny10mm';
% leadfield = 'Lliny1mm';
% leadfield = 'Lsurf10mm';

stage.leadfield = leadfield;
% Get the config
cfg = ftb.prepare_leadfield(stage);
% Create the model
cfg = ftb.create_leadfield(cfg);

% ftb.check_leadfield(cfg);

%% Stage 4
% Create simulated data
% dipolesim = 'SM1snr0';
dipolesim = 'SS1snr0';
% dipolesim = 'SN1';

stage.dipolesim = dipolesim;
% Get the config
cfg = ftb.prepare_dipolesim(stage);
% Create the model
cfg = ftb.create_dipolesim(cfg);

% ftb.check_dipolesim(cfg);

%% Stage 5
% Source localization
beamformer = 'BF1';

stage.beamformer = beamformer;
% Get the config
cfg = ftb.prepare_sourceanalysis(stage);
% Create the model
cfg = ftb.create_sourceanalysis(cfg);

% Check results
cfg.checks = {'anatomical', 'headmodel', 'scatter'};
cfg.method = 'all';
% cfg.checks = {'headmodel', 'scatter'};
% cfg.checks = {'scatter'};
% cfg.method = 'outer';
% cfg.outer.size = 15;
% cfg.method = 'plane';
% cfg.plane.axis = 'x';
% cfg.plane.value = -50;
ftb.check_sourceanalysis(cfg);

%% Stage 4b
% Simulate noise for contrast plot
dipolesimnoise = 'SNabs0-01';

stage.dipolesim = dipolesimnoise;
% Get the config
cfg = ftb.prepare_dipolesim(stage);
% Create the model
cfg = ftb.create_dipolesim(cfg);

%% Stage 5b
% Source localization with noise only
stage.beamformer = beamformer;
% Get the config
cfg = ftb.prepare_sourceanalysis(stage);
% Create the model
cfg = ftb.create_sourceanalysis(cfg);

%% Stage 5c
% Check results with noise contrast
stage.dipolesim = dipolesim;
stage.beamformer = beamformer;
% Get the config
cfg = ftb.prepare_sourceanalysis(stage);

% Check results with contrast
cfgcopy = cfg;
cfgcopy.contrast = dipolesimnoise;
cfgcopy.checks = {'anatomical', 'headmodel', 'scatter'};
ftb.check_sourceanalysis(cfgcopy);
