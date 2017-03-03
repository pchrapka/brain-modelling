%% check_mri_atlas_fit

%% load pipeline
stimulus = 'std';
subject = 3; 
deviant_percent = 10;
patch_type = 'aal-coarse-19';
[pipeline,outdir] = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_type);

%% get original leadfield
lf_file = pipeline.steps{end}.get_dep('ftb.Leadfield').leadfield;
lf = loadfile(lf_file);

mri_file = pipeline.steps{end}.get_dep('ftb.MRI').mri_mat;
mri = loadfile(mri_file);

source_file = pipeline.steps{end}.sourceanalysis;
sources = loadfile(source_file);

%%
atlas_file = fullfile(ft_get_dir(),'template','atlas','aal','ROI_MNI_V4.nii');
atlas = ft_read_atlas(atlas_file);

%%
nlabels = length(atlas.tissuelabel);

cfg = [];
cfg.parameter = 'avg.pow'; % spoof avg.pow?
source_int = ft_sourceinterpolate(cfg, sources, mri);

for i=1:nlabels
    % create mask
    cfg = [];
    cfg.inputcoord = 'mni';
    cfg.atlas = atlas;
    cfg.roi = atlas.tissuelabel{i};
    
    mask = ft_volumelookup(cfg,lf);
    
    % add mask to sources
    source_int.mask = mask;
    
    % plot source power with mask
    cfg = [];
    cfg.method = 'slice';
    cfg.funparameter = 'avg.pow';
    cfg.maskparameter = 'mask';
    cfg.funcolorlim = [0 1];
    ft_sourceplot(cfg, source_int);
    
    prompt = 'press any key to continue, q to quit\n';
    result = input(prompt,'s');
    switch lower(result)
        case 'q'
            break;
        otherwise
    end
            
end
