%% check_mri_atlas_fit

%% load pipeline
stimulus = 'std';
subject = 3; 
deviant_percent = 10;
patch_type = 'aal-coarse-19';
[pipeline,outdir] = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_type);

%% get data from pipeline
lf_file = pipeline.steps{end}.get_dep('ftb.Leadfield').leadfield;
lf = loadfile(lf_file);

mri_file = pipeline.steps{end}.get_dep('ftb.MRI').mri_mat;
mri = loadfile(mri_file);
mri = ft_convert_units(mri,lf.unit);

source_file = pipeline.steps{end}.sourceanalysis;
sources = loadfile(source_file);

%%
sources_fake = copyfields(sources,[],{'dim','pos','cfg'});
sources_fake.time = 1;
sources_fake.method = 'avg';
sources_fake.inside = lf.inside;
sources_fake.avg.pow = zeros(size(sources_fake.inside));
sources_fake.avg.pow(lf.inside) = 1;


%% reslice
mri = ft_volumereslice([], mri);

%% interpolate
cfg = [];
cfg.parameter = 'avg.pow';
cfg.downsample = 4;
source_int = ft_sourceinterpolate(cfg, sources_fake, mri);

%%
atlas_file = fullfile(ft_get_dir(),'template','atlas','aal','ROI_MNI_V4.nii');
atlas = ft_read_atlas(atlas_file);
atlas = ft_convert_units(atlas,lf.unit);

%%
nlabels = length(atlas.tissuelabel);

flag_locs = true;

if flag_locs
    loc1 = [ -45.0, -3.2, 16.2];
    loc2 = [ 45.0, -3.2, 16.2];
    locs = [loc1; loc2];
    locsmni = tal2mni(locs);
    locsmni = locsmni/10; % convert to cm
    
    
    nlocs = size(locsmni,1);
    
    for i=1:nlocs
        % create mask
        cfg = [];
        cfg.inputcoord = 'mni';
        cfg.atlas = atlas;
        cfg.roi = locsmni(i,:);
        cfg.sphere = 2;
        cfg.round2nearestvoxel = 'yes';
        
        mask = ft_volumelookup(cfg,source_int);
        
        % add mask to sources
        source_int.mask = mask;
        
        % plot source power with mask
        cfg = [];
        cfg.method = 'slice';
        cfg.nslices = 40;
        cfg.funparameter = 'avg.pow';
        %cfg.maskparameter = cfg.funparameter;
        cfg.maskparameter = 'mask';
        cfg.funcolorlim = [0 1.2];
        cfg.funcolormap = 'hot';
        cfg.opacitylim = [0 1.2];
        cfg.opacitymap = 'rampup';
        ft_sourceplot(cfg, source_int);
        
        set(gcf,'Name',sprintf('loc %d',i),...
            'Position',[1 1 1000 600]);
        
        prompt = 'press any key to continue, q to quit\n';
        result = input(prompt,'s');
        switch lower(result)
            case 'q'
                close(gcf);
                break;
            otherwise
        end
        close(gcf);
        
    end
else
    for i=1:nlabels
        
        % plot source power with mask
        cfg = [];
        cfg.method = 'slice';
        cfg.nslices = 40;
        cfg.funparameter = 'avg.pow';
        %cfg.maskparameter = cfg.funparameter;
        if flag_locs
            cfg.maskparameter = 'mask';
        else
            cfg.roi = atlas.tissuelabel{i};
            cfg.atlas = atlas;
        end
        cfg.funcolorlim = [0 1.2];
        cfg.funcolormap = 'hot';
        cfg.opacitylim = [0 1.2];
        cfg.opacitymap = 'rampup';
        ft_sourceplot(cfg, source_int);
        
        set(gcf,'Name',atlas.tissuelabel{i},...
            'Position',[1 1 1000 600]);
        
        prompt = 'press any key to continue, q to quit\n';
        result = input(prompt,'s');
        switch lower(result)
            case 'q'
                close(gcf);
                break;
            otherwise
        end
        close(gcf);
        
    end
    
end