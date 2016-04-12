%% exp08_beamform_eeg_sim
% Goal: 
%   Apply patch beamformer to simulated EEG data

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
[datadir,subject_file,subject_name] = get_coma_data(22);

subject_specific = true; % select electrode configuration

% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-common','fb');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

%% Set up beamformer analysis
hm_type = 3;
analysis = create_analysis(out_folder,...
    'datadir',datadir,...
    'subject_file', subject_file,...
    'subject_name', subject_name,...
    'hm_type',hm_type);

%% EEG simulation

% Create custom configs
% DSarind_cm();
switch hm_type
    case 3
        DSstd_dip3_sine_cm();
        params_dsim = 'DSstd-dip3-sine-cm.mat';
        dsim = ftb.DipoleSim(params_dsim,'std-dip3-sine-cm');
    otherwise
        params_dsim = 'DSdip3-sine-cm.mat';
        dsim = ftb.DipoleSim(params_dsim,'dip3-sine-cm');
end
analysis.add(dsim);
dsim.force = true;

% % Process pipeline to check dipole locations
% analysis.init();
% analysis.process();
% 
% % Can be ommitted
% if exist('dsim','var')
%     figure;
%     dsim.plot({'brain','skull','scalp','fiducials','dipole'});
% end

%% Patch beamformer

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
        bf = ftb.BeamformerPatch(params_bf,'exp08');
        analysis.add(bf);
        
    case 'regular'
        % Regular Beamformer
        params_bf = [];
        params_bf.ft_sourceanalysis.method = 'lcmv';
        params_bf.ft_sourceanalysis.lcmv.keepmom = 'yes';
        bf = ftb.Beamformer(params_bf,'reg-exp08');
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
