%% check_dipoles

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
source_file = pipeline.steps{end}.sourceanalysis;
sources = loadfile(source_file);

%%
atlas_file = fullfile(ft_get_dir(),'template','atlas','aal','ROI_MNI_V4.nii');
atlas = ft_read_atlas(atlas_file);
atlas = ft_convert_units(atlas,lf.unit);

%%

% in Talaraich coordinates
% average
% loc1 = [ -45.0, -3.2, 16.2];
% loc2 = [ 45.0, -3.2, 16.2];

% participant 3
loc1 = [-34.357361   -8.505583   +9.360396];
loc2 = [+34.357361   -8.505583   +9.360396];

locs = [loc1; loc2];
locsmni = tal2mni(locs);
locsmni = locsmni/10; % convert to cm

nlocs = size(locsmni,1);

for i=1:nlocs
    % create mask
    cfg = [];
    cfg.roi = locsmni(i,:);
    cfg.round2nearestvoxel = 'yes';
    cfg.sphere = 2; % don't know what units
    
    mask = ft_volumelookup(cfg,lf);
    
    
    lf2 = lf;
    lf2.mask = mask;
    
    % get mask labels
    cfg = [];
    cfg.inputcoord = 'mni';
    cfg.atlas = atlas;
    cfg.maskparameter = 'mask';
    labels = ft_volumelookup(cfg,lf2);
    
    [tmp ind] = sort(labels.count,1,'descend');
    sel = find(tmp);
    found_areas = {};
    for j = 1:length(sel)
        found_areas{j,1} = [num2str(labels.count(ind(j))) ': ' labels.name{ind(j)}];
    end
    
    disp(found_areas);
end
