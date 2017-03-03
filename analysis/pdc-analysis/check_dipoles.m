%% check_dipoles

%% load pipeline
stimulus = 'std';
subject = 3; 
deviant_percent = 10;
patch_type = 'aal-coarse-19';
[pipeline,outdir] = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_type);

%% get original leadfield
lf_file = pipeline.steps{end}.lf.leadfield;

%%
atlas_file = fullfile(ft_get_dir(),'template','atlas','aal','ROI_MNI_V4.nii');
atlas = ft_read_atlas(atlas_file);

%%

% in Talaraich coordinates
loc1 = [ -45.0, -3.2, 16.2];
loc2 = [ 45.0, -3.2, 16.2];

cfg = [];
cfg.inputcoord = 'tal';
cfg.atlas = atlas;
cfg.roi = [loc1; loc2];
cfg.round2nearestvoxel = 'yes';

ft_volumedownsample(cfg,