%% exp08_beamform_patch_eeg
% Goal: 
%   Apply patch beamformer to EEG data

close all;

% plot flags
plot_beampattern = false;
plot_beampattern_save = false;

plot_patch_resolution = false;
plot_patch_resolution_save = false;

% beamformer type
% bf_type = 'regular';
bf_type = 'patch';

%% Analysis file path params

% subject specific info
datadir = '/home/phil/projects/data-coma-richard/BC-HC-YOUTH/Cleaned';
% subject_file = 'BC.HC.YOUTH.P020-10834';
% subject_file = 'BC.HC.YOUTH.P021-10852';
subject_file = 'BC.HC.YOUTH.P022-9913';
% subject_file = 'BC.HC.YOUTH.P023-10279';
subject_name = strrep(subject_file,'BC.HC.YOUTH.','');

% stimulus = 'odd';
stimulus = 'std';

% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-fb');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

%% Set up beamformer analysis
hm_type = 3;
analysis = create_bfanalysis_subject_specific(out_folder,...
    'datadir',datadir,...
    'subject_file', subject_file,...
    'subject_name', subject_name,...
    'hm_type',hm_type);

%% EEG

% TODO Need to split this up into single trials
% It's not dependent on others so I could process this separately and then
% do each trial separately, loading files for ft_definetrial (fake),
% ft_preprocessing (single trial)

params_eeg = EEGstddev(datadir, subject_file, stimulus);
eeg = ftb.EEG(params_eeg, stimulus);
analysis.add(eeg);

% % split up trials into singles
% params_eeg_split = [];
% params_eeg_split.ft_timelockanalysis.covariance = 'yes';
% params_eeg_split.ft_timelockanalysis.covariancewindow = 'all';
% params_eeg_split.ft_timelockanalysis.keeptrials = 'no';
% params_eeg_split.ft_timelockanalysis.removemean = 'yes';
% eeg_split = ftb.EEGTrial(params_eeg_split,'');
% analysis.add(eeg_split);

%% Beamformer

switch bf_type
    case 'patch'
        % Set up an atlas
        matlab_dir = userpath;
        pathstr = fullfile(matlab_dir(1:end-1),'fieldtrip-20160128','template','atlas','aal');
        atlas_file = fullfile(pathstr,'ROI_MNI_V4.nii');
        
        params_bf = [];
        params_bf.atlas_file = atlas_file;
        params_bf.ft_sourceanalysis.method = 'lcmv';
        params_bf.ft_sourceanalysis.lcmv.keepmom = 'yes';
        bf = ftb.BeamformerPatchTrial(params_bf,'lcmvmom');
        analysis.add(bf);
        
    case 'regular'
        % Regular Beamformer
        params_bf = [];
        params_bf.ft_sourceanalysis.method = 'lcmv';
        params_bf.ft_sourceanalysis.lcmv.keepmom = 'yes';
        bf = ftb.BeamformerTrial(params_bf,'lcmvmom');
        analysis.add(bf);
    otherwise
        error('unknown beamformer');
end

%% Process pipeline
analysis.init();
analysis.process();

%% Plot beampatterns
% NOTE beampatterns are data dependent

if plot_beampattern
    cfgsave = [];
    if plot_beampattern_save
        [pathstr,~,~] = fileparts(bf.sourceanalysis);
        cfgsave.out_dir = fullfile(pathstr,'img');
        
        if ~exist(cfgsave.out_dir,'dir')
            mkdir(cfgsave.out_dir);
        end
    end
    
    % get patches
    patches = ftb.patches.get_aal_coarse(atlas_file);
    % loop through patches
    for i=1:length(patches)
        % use patch name as seed
        seed = patches(i).name;
        
        thresh = 0.6;
        bf.plot_beampattern(seed,'method','slice','mask','thresh','thresh',thresh);
        title(seed);
        
        save_fig(cfgsave, sprintf('beampattern-%s-%d',strrep(seed,' ','-'),thresh*100), plot_beampattern_save);
    end
    
end

%% Plot patch resolution
% NOTE Nice way to evaluate the resolution of all the pathches

if plot_patch_resolution
    cfgsave = [];
    if plot_patch_resolution_save
        [pathstr,~,~] = fileparts(bf.sourceanalysis);
        cfgsave.out_dir = fullfile(pathstr,'img');
        
        if ~exist(cfgsave.out_dir,'dir')
            mkdir(cfgsave.out_dir);
        end
    end
    
    % get patches
    patches = ftb.patches.get_aal_coarse(atlas_file);
    % loop through patches
    for i=1:length(patches)
        % use patch name as seed
        seed = patches(i).name;
        
        bf.plot_patch_resolution(seed,'method','slice');
        title(seed);
        save_fig(cfgsave, sprintf('patch-res-%s',strrep(seed,' ','-')), plot_patch_resolution_save);
    end
end

%% Plot source analysis results

figure;
bf.plot({'brain','skull','scalp','fiducials','dipole'});

% figure;
% bf.plot_scatter([]);
bf.plot_anatomical('method','slice');
% 
% figure;
% bf.plot_moment('2d-all');
% figure;
% bf.plot_moment('2d-top');
% figure;
% bf.plot_moment('1d-top');