%% exp07_beamform_eeg_mmn_contrast
% Goal: 
%   Beamform MMN EEG, with prestimulus contrast

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

hm_type = 3;

switch hm_type
    case 1
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
        
    case 2
        
        % MRI
        params_mri = 'MRIS01.mat';
        m = ftb.MRI(params_mri,'S01');
        
        % Headmodel
        params_hm = 'HMopenmeeg-cm.mat';
        hm = ftb.Headmodel(params_hm,'openmeeg-cm');
        
        % Add steps
        analysis.add(m);
        analysis.add(hm);
        
        % Process pipeline
        analysis.init();
        analysis.process();
        
    case 3
        % MRI
        params_mri = [];
        params_mri.mri_data = 'std';
        m = ftb.MRI(params_mri,'std');
        
        % Headmodel
        params_hm = [];
        params_hm.fake = '';
        hm = ftb.Headmodel(params_hm,'std-cm');
        
        % Add steps
        analysis.add(m);
        analysis.add(hm);
        
        % Process pipeline
        analysis.init();
        m.load_file('mri_mat', 'standard_mri.mat');
        m.load_file('mri_segmented', 'standard_seg.mat');
        m.load_file('mri_mesh', 'MRIS01.mat'); % fake this
        hm.load_file('mri_headmodel', 'standard_bem.mat');
        % process should ignore the files above
        analysis.process();
        
        hm.plot({'scalp','skull','brain','fiducials'});
end

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
% params_lf = 'L1cm-norm.mat';
% lf = ftb.Leadfield(params_lf,'1cm-norm');
params_lf = 'L1cm.mat';
lf = ftb.Leadfield(params_lf,'1cm');
analysis.add(lf);
lf.force = false;

%% Compute MMN

eeg_name = '';

% EEG Deviant
params_eeg.ft_definetrial = [];
params_eeg.ft_definetrial.dataset = fullfile(datadir,[subject '-MMNf.eeg']);
% use default function
params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
params_eeg.ft_definetrial.trialdef.eventvalue = {'S 16'}; % deviant
params_eeg.ft_definetrial.trialdef.prestim = 0.2; % in seconds
params_eeg.ft_definetrial.trialdef.poststim = 0.5; % in seconds

% assuming data was already processed
%params_eeg.ft_preprocessing.method = 'trial';
params_eeg.ft_preprocessing.continuous = 'yes';
params_eeg.ft_preprocessing.detrend = 'no';
params_eeg.ft_preprocessing.demean = 'yes';
%params_eeg.ft_preprocessing.baselinewindow = [-0.2 0];
params_eeg.ft_preprocessing.channel = 'EEG';

params_eeg.ft_timelockanalysis.covariance = 'no';
params_eeg.ft_timelockanalysis.keeptrials = 'no';
params_eeg.ft_timelockanalysis.removemean = 'yes';

eeg_dev = ftb.EEG(params_eeg,[eeg_name 'dev']);
analysis.add(eeg_dev);
eeg_dev.force = false;

% EEG Standard
% use the same params from deviant case
params_eeg.ft_definetrial.trialdef.eventvalue = {'S 11'}; % standard
eeg_std = ftb.EEG(params_eeg,[eeg_name 'std']);
analysis.add(eeg_std);
eeg_std.force = false;

params_eeg_mmn = [];
params_eeg_mmn.ft_timelockanalysis.covariance = 'yes';
params_eeg_mmn.ft_timelockanalysis.covariancewindow = 'all';
params_eeg_mmn.ft_timelockanalysis.keeptrials = 'no';
params_eeg_mmn.ft_timelockanalysis.removemean = 'yes';
eeg_mmn = ftb.EEGMMN(params_eeg_mmn,[eeg_name 'mmn']);
analysis.add(eeg_mmn);
eeg_mmn.force = false;

% need file for next step
analysis.init();
analysis.process();
eeg_mmn.force = false;

%% Separate EEG into pre and post
% EEG
params_eeg = [];
params_eeg.ft_definetrial = [];

% specify pre post times
params_eeg.pre.ft_redefinetrial.toilim = [-0.2 0];
params_eeg.pre.ft_timelockanalysis.covariance = 'yes';
params_eeg.pre.ft_timelockanalysis.covariancewindow = 'all'; % should be default

params_eeg.post.ft_redefinetrial.toilim = [0 0.5];
params_eeg.post.ft_timelockanalysis.covariance = 'yes';
params_eeg.post.ft_timelockanalysis.covariancewindow = 'all'; % should be default

eeg_prepost = ftb.EEGPrePost(params_eeg,[eeg_name]);
analysis.add(eeg_prepost);

% fake preprocessed and load timelock
analysis.init();
% FIXME for this to work, no previous steps can have the force flag set
% FIXME I should have flags for each artifact whether it's processed or
% loaded, so each artifact should be an object
eeg_prepost.load_file('definetrial', 'MRIS01.mat'); % super fake
eeg_prepost.load_file('preprocessed', eeg_mmn.preprocessed);
eeg_prepost.load_file('timelock', eeg_mmn.timelock);
eeg_prepost.force = false;
% process should ignore the files above
analysis.process();

% Beamformer - Common
params_bfcommon = [];
params_bfcommon.ft_sourceanalysis.method = 'lcmv';
params_bfcommon.ft_sourceanalysis.lcmv.keepmom = 'no';
params_bfcommon.ft_sourceanalysis.lcmv.keepfilter = 'yes';
bf_common = ftb.Beamformer(params_bfcommon,'common');
analysis.add(bf_common);
bf_common.force = false;

%% Set up contrast

params_bfcontrast = [];
params_bfcontrast.ft_sourceanalysis.method = 'lcmv';
params_bfcontrast.ft_sourceanalysis.lcmv.keepmom = 'yes';
bf_contrast = ftb.BeamformerContrast(params_bfcontrast,'');
analysis.add(bf_contrast);
bf_contrast.force = false;

%% Process pipeline
analysis.init();
analysis.process();

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
    % figure;
    % bf.plot({'brain','skull','scalp','fiducials'});
    
    options = [];
    %options.funcolorlim = [-0.2 0.2];
    options.funcolormap = 'jet';
    
    %figure;
    %bf_contrast.plot_scatter([]);
    bf_contrast.plot_anatomical('method','slice','options',options);
    bf_contrast.plot_anatomical('method','ortho','options',options);
    bf_contrast.plot_anatomical('method','slice','options',options,'mask','max');
    bf_contrast.plot_anatomical('method','ortho','options',options,'mask','max');
    
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
    
    %figure;
    %bf_contrast.pre.plot_scatter([]);
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
    
    %figure;
    %bf_contrast.post.plot_scatter([]);
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