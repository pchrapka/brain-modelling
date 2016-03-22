%% exp08_atlas

%% load the atlas
matlab_dir = userpath;
pathstr = fullfile(matlab_dir(1:end-1),'fieldtrip-20160128','template','atlas','aal');
atlas_file = fullfile(pathstr,'ROI_MNI_V4.nii');

atlas = ft_read_atlas(atlas_file);    

%% plot atlas slices
plot_atlas(atlas,'nslices',20);

%% plot atlas
cfg              = [];
cfg.method       = 'ortho';
cfg.funparameter = [];%'brick0';
cfg.funcolormap  ='jet';
ft_sourceplot(cfg, atlas)

%%
% http://www.fieldtriptoolbox.org/faq/how_can_i_map_source_locations_between_two_different_representations

din = load('standard_sourcemodel3d10mm.mat');


cfg = []; 
cfg.interpmethod = 'nearest'; 
cfg.parameter = 'tissue'; 
sourcemodel2 = ft_sourceinterpolate(cfg, atlas, din.sourcemodel); 
% now sourcemodel2 has a tissue field with the index of the anatomical
% label for each voxel

% Useful links
% http://www.fieldtriptoolbox.org/example/create_single-subject_grids_in_individual_head_space_that_are_all_aligned_in_brain_atlas_based_mni_space,
% http://www.fieldtriptoolbox.org/faq/how_can_i_map_source_locations_between_two_different_representations
% http://www.fieldtriptoolbox.org/template/atlas
% http://www.fieldtriptoolbox.org/faq/how_can_i_determine_the_anatomical_label_of_a_source