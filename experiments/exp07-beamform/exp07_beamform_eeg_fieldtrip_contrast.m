%% exp07_beamform_eeg_fieldtrip_contrast
% Goal: 
%   Beamform EEG, stimulus with prestimulus contrast
%
%   Following fieldtrip tutorial 
%   http://www.fieldtriptoolbox.org/tutorial/aarhus/beamformingerf
%
%   The data is located at:
%   ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/natmeg/oddball1_mc_downsampled.fif

close all;

doplot = true;
datahand = 'right';

datadir = '/home/phil/projects/brain-modelling/experiments/exp07-mqrd-lsl-beamform/data';
dataset = 'oddball1_mc_downsampled.fif';
datapreprocessed = 'data_eeg_reref_ica.mat';

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

% TODO Check http://www.fieldtriptoolbox.org/tutorial/natmeg/dipolefitting
% Requires processing from raw DICOM format
% Let's try using our typical head model and see what happens

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
params_e.elec_orig = fullfile(datadir,dataset);

% Only way is to do interactive which is pretty difficult without
% fiducials
params_e.units = 'cm';
params_e.ft_electroderealign.method = 'interactive';
headshape = hm.get_mesh('scalp','mm'); % use mm for fitting
params_e.ft_electroderealign.headshape = headshape;

e = ftb.Electrodes(params_e,'FT');
% e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
analysis.add(e);
e.force = false;

% Process pipeline
analysis.init();
analysis.process();
e.force = false;

% % Manually rename channel
% % NOTE This is why the electrodes are processed ahead of time
% elec = ftb.util.loadvar(e.elec_aligned);
% idx = cellfun(@(x) isequal(x,'Afz'),elec.label);
% if any(idx)
%     elec.label{idx} = 'AFz';
%     save(e.elec_aligned,'elec');
% end

e.plot({'scalp','fiducials','electrodes-aligned','electrodes-labels'});


%% Create the rest of the pipeline

% load preprocessed ft data
datapre = ftb.util.loadvar(fullfile(datadir,datapreprocessed));
datapre = rmfield(datapre,'grad');
% display channels labels
% disp(datapre.label); 
% sort into left and right hand response
switch datahand
    case 'left'
        cfg = [];
        cfg.trials = find(datapre.trialinfo(:,1) == 256);
        data_eeg = ft_redefinetrial(cfg, datapre);
    case 'right'
        cfg = [];
        cfg.trials = find(datapre.trialinfo(:,1) == 4096);
        data_eeg = ft_redefinetrial(cfg, datapre);
end
datahandfile = ['data' datahand '.mat'];
save(fullfile(datadir, datahandfile),'data_eeg');

% Create custom configs
% DSarind_cm();
BFlcmv_exp07();

% Leadfield
% params_lf = 'L1cm-norm.mat';
% lf = ftb.Leadfield(params_lf,'1cm-norm');
params_lf = [];
params_lf.ft_prepare_leadfield.normalize = 'no';
% params_lf.ft_prepare_leadfield.grid.xgrid = -6:resolution:11;
% params_lf.ft_prepare_leadfield.grid.ygrid = -7:resolution:6;
% params_lf.ft_prepare_leadfield.grid.zgrid = -1:resolution:12;
params_lf.ft_prepare_leadfield.tight = 'yes';
params_lf.ft_prepare_leadfield.grid.resolution = 1;
params_lf.ft_prepare_leadfield.grid.unit = 'cm';
params_lf.ft_prepare_leadfield.channel = data_eeg.label;
lf = ftb.Leadfield(params_lf,'1cm-FT');
analysis.add(lf);
lf.force = false;

% EEG
eeg_name = datahand;

% NOTE Faking preprocessing for quick and dirty attempt
% Show events
% params_eeg = [];
% params_eeg.ft_definetrial = [];
% params_eeg.ft_definetrial.dataset = fullfile(datadir,dataset);
% params_eeg.ft_definetrial.trialdef.eventtype = '?';
% 
% eeg_temp = ftb.EEG(params_eeg, eeg_name);
% analysis.add(eeg_temp);
% eeg_temp.force = false;
% analysis.init();
% analysis.process();
% Event type STI101 values: 1 (std) 2 (odd) 5
% Event type STI102 values: 256 (left) 4096 (right)

% % EEG Standard
% params_eeg = [];
% params_eeg.ft_definetrial = [];
% params_eeg.ft_definetrial.dataset = fullfile(datadir,dataset);
% % use default function
% params_eeg.ft_definetrial.trialdef.stim_triggers = [1 2];
% % params_eeg.ft_definetrial.trialdef.rsp_triggers = [256 4096];
% params_eeg.ft_definetrial.trialdef.rsp_triggers = 4096; % just use right side
% params_eeg.ft_definetrial.trialfun = 'trialfun_oddball_responselocked';
% params_eeg.ft_definetrial.trialdef.prestim = 1.5; % in seconds
% params_eeg.ft_definetrial.trialdef.poststim = 2; % in seconds
% 
% % assuming data was already processed
% params_eeg.ft_preprocessing.continuous = 'yes';
% params_eeg.ft_preprocessing.demean = 'yes';
% params_eeg.ft_preprocessing.channel = 'EEG';
% 
% % in tutorial
% % params_eeg.ft_preprocessing.dftfilter = 'yes';
% % params_eeg.ft_preprocessing.dftfreq = [50 100];
% 
% % not in tutorial
% % params_eeg.ft_preprocessing.detrend = 'no';
% % params_eeg.ft_preprocessing.baselinewindow = [-0.2 0];
% % params_eeg.ft_preprocessing.method = 'trial';
% 
% % TODO Artifact rejection
% % TODO Split EEG into preprocessing and timelock
% 
% params_eeg.ft_timelockanalysis.covariance = 'yes';
% params_eeg.ft_timelockanalysis.covariancewindow = [-0.15 0.15];
% params_eeg.ft_timelockanalysis.vartrllength = 2;
% params_eeg.ft_timelockanalysis.keeptrials = 'yes'; % should be default
% % not in tutorial
% % params_eeg.ft_timelockanalysis.removemean = 'yes';

% EEGPrePorst
% We will load preprocessed data

params_eeg = [];
params_eeg.ft_definetrial = [];
params_eeg.ft_timelockanalysis.covariance = 'yes';
params_eeg.ft_timelockanalysis.covariancewindow = [-0.15 0.15];
params_eeg.ft_timelockanalysis.vartrllength = 2;
params_eeg.ft_timelockanalysis.keeptrials = 'no'; % should be default
% not in tutorial
% params_eeg.ft_timelockanalysis.removemean = 'yes';

% specify pre post times
params_eeg.pre.ft_redefinetrial.toilim = [-0.15 -0.05];
params_eeg.pre.ft_timelockanalysis.covariance = 'yes';
params_eeg.pre.ft_timelockanalysis.covariancewindow = 'all'; % should be default
params_eeg.pre.ft_timelockanalysis.vartrllength = 2;

params_eeg.post.ft_redefinetrial.toilim = [0.05 0.15];
params_eeg.post.ft_timelockanalysis.covariance = 'yes';
params_eeg.post.ft_timelockanalysis.covariancewindow = 'all'; % should be default
params_eeg.post.ft_timelockanalysis.vartrllength = 2;

eeg_prepost = ftb.EEGPrePost(params_eeg,eeg_name);
analysis.add(eeg_prepost);
eeg_prepost.force = false;

% fake preprocessed files

analysis.init();
eeg_prepost.load_file('definetrial', 'MRIS01.mat'); % super fake
eeg_prepost.load_file('preprocessed', fullfile(datadir,datahandfile));
% process should ignore the files above
analysis.process();

%% Beamformer - Common
params_bfcommon = [];
params_bfcommon.ft_sourceanalysis.channel = data_eeg.label;
params_bfcommon.ft_sourceanalysis.method = 'lcmv';
params_bfcommon.ft_sourceanalysis.lcmv.keepmom = 'no';
params_bfcommon.ft_sourceanalysis.lcmv.keepfilter = 'yes';
bf_common = ftb.Beamformer(params_bfcommon,'common');
analysis.add(bf_common);
bf_common.force = false;

%% Set up contrast

params_bfcontrast = [];
params_bfcontrast.ft_sourceanalysis.channel = data_eeg.label;
params_bfcontrast.ft_sourceanalysis.method = 'lcmv';
params_bfcontrast.ft_sourceanalysis.lcmv.keepmom = 'yes';
bf_contrast = ftb.BeamformerContrast(params_bfcontrast,'');
analysis.add(bf_contrast);
bf_contrast.force = false;

%% Process pipeline
analysis.init();
analysis.process();

%eeg_prepost.print_labels();

% FIXME NOT WORKING!!!

%% Plot all results
% TODO Check individual trials
% bf.remove_outlier(10);

% figure;
% cfg = [];
% cfg.datafile = fullfile(datadir,datafile);
% cfg.continuous = 'yes';
% ft_databrowser(cfg);

% figure;
% cfg = ftb.util.loadvar(eeg_std.definetrial);
% ft_databrowser(cfg);

%% EEG plots
plot_preprocessed = false;
plot_timelock = false;

if plot_preprocessed
    type = 'all';
    switch type
        case 'all'
            eegObj = eeg_prepost;
        case 'pre'
            eegObj = eeg_prepost.pre;
        case 'post'
            eegObj = eeg_prepost.post;
    end
    cfg = [];
    cfg.channel = 'Cz';
    eegObj.plot_data('preprocessed',cfg)
end

if plot_timelock
    %type = 'post';
    %type = 'pre';
    type = 'all';
    switch type
        case 'all'
            eegObj = eeg_prepost;
        case 'pre'
            eegObj = eeg_prepost.pre;
        case 'post'
            eegObj = eeg_prepost.post;
    end
    cfg = [];
    %cfg.channel = 'Cz';
    eegObj.plot_data('timelock',cfg)
end

%% Beamformer plots
plot_bf = true;
plot_moment = false; % no moment in contrast

if plot_bf
    options = [];
    options.funcolorlim = [-0.2 0.2];
    options.funcolormap = 'jet';
    
    figure;
    %bf_contrast.plot_scatter([]);
    bf_contrast.plot_anatomical('method','slice','options',options,'mask','thresh','thresh',0.3);
    bf_contrast.plot_anatomical('method','ortho','options',options,'mask','thresh','thresh',0.3);
    
    if plot_moment
        figure;
        bf_contrast.plot_moment('2d-all');
        figure;
        bf_contrast.plot_moment('2d-top');
        figure;
        bf_contrast.plot_moment('1d-top');
    end
    
    options = [];
    %options.funcolorlim = [-0.2 0.2];
    options.funcolormap = 'jet';

    figure;
    bf_contrast.pre.plot_scatter([]);
    bf_contrast.pre.plot_anatomical('method','slice','options',options);
    bf_contrast.pre.plot_anatomical('method','ortho','options',options);
    
    if plot_moment
        figure;
        bf_contrast.pre.plot_moment('2d-all');
        figure;
        bf_contrast.pre.plot_moment('2d-top');
        figure;
        bf_contrast.pre.plot_moment('1d-top');
    end

    figure;
    bf_contrast.post.plot_scatter([]);
    bf_contrast.post.plot_anatomical('method','slice','options',options);
    bf_contrast.post.plot_anatomical('method','ortho','options',options);
    
    if plot_moment
        figure;
        bf_contrast.post.plot_moment('2d-all');
        figure;
        bf_contrast.post.plot_moment('2d-top');
        figure;
        bf_contrast.post.plot_moment('1d-top');
    end
end
