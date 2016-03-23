%% exp08_beamform_eeg_sim
% Goal: 
%   Apply beamforming to simulated EEG data

close all;

doplot = true;

datadir = '/home/phil/projects/data-coma-richard/BC-HC-YOUTH/Cleaned';
% subject = 'BC.HC.YOUTH.P020-10834';
% subject = 'BC.HC.YOUTH.P021-10852';
subject = 'BC.HC.YOUTH.P022-9913';
% subject = 'BC.HC.YOUTH.P023-10279';
subject_name = strrep(subject,'BC.HC.YOUTH.','');

subject_specific = true; % select electrode configuration

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
    name_e = subject_name;
else
    % Not sure what cap to use easycap-M1 has right channel names but
    % too many
    error('fix me');
end

e = ftb.Electrodes(params_e,name_e);
if subject_specific
    e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
else
    error('fix me');
end
analysis.add(e);
e.force = false;

% Process pipeline
analysis.init();
analysis.process();
e.force = false;

if subject_specific
    % Manually rename channel
    % NOTE This is why the electrodes are processed ahead of time
    elec = ftb.util.loadvar(e.elec_aligned);
    idx = cellfun(@(x) isequal(x,'Afz'),elec.label);
    if any(idx)
        elec.label{idx} = 'AFz';
        save(e.elec_aligned,'elec');
    end
end

e.plot({'scalp','fiducials','electrodes-aligned','electrodes-labels'});


%% Leadfield

% Leadfield
params_lf = [];
params_lf.ft_prepare_leadfield.normalize = 'yes';
params_lf.ft_prepare_leadfield.tight = 'yes';
params_lf.ft_prepare_leadfield.grid.resolution = 1;
params_lf.ft_prepare_leadfield.grid.unit = 'cm';
lf = ftb.Leadfield(params_lf,'1cm-full');
analysis.add(lf);
lf.force = false;

%% EEG simulation

% Create custom configs
% DSarind_cm();

params_dsim = 'DSdip3-sine-cm.mat';
dsim = ftb.DipoleSim(params_dsim,'dip3-sine-cm');
% params_dsim = 'DSsine-cm.mat';
% dsim = ftb.DipoleSim(params_dsim,'sine-cm');
analysis.add(dsim);
dsim.force = true;

%% Patch beamformer filters
% Set up an atlas
matlab_dir = userpath;
pathstr = fullfile(matlab_dir(1:end-1),'fieldtrip-20160128','template','atlas','aal');
atlas_file = fullfile(pathstr,'ROI_MNI_V4.nii');

% TODO Compute filters
% Needs leadfields and an atlas
data = ftb.util.loadvar(dsim.timelock);
leadfield = ftb.util.loadvar(lf.leadfield);
patches = get_patches_aal(atlas_file);
filters = beamform_lcmv_patch(data, leadfield, atlas_file, patches);


%% Beamformer
% Create custom config
% BFlcmv_exp07();

params_bf = [];
params_bf.ft_sourceanalysis.filter = ; % TODO add filters
bf = ftb.Beamformer(params_bf,'lcmv-patch');
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

figure;
bf.plot_moment('2d-all');
figure;
bf.plot_moment('2d-top');
figure;
bf.plot_moment('1d-top');