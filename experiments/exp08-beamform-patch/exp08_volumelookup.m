%% exp08_volumelookup

% Tutorial
% http://www.fieldtriptoolbox.org/example/create_single-subject_grids_in_individual_head_space_that_are_all_aligned_in_brain_atlas_based_mni_space,

%% Set up template grid
din = load('standard_singleshell');
 
cfg = [];
cfg.grid.xgrid  = -20:1:20;
cfg.grid.ygrid  = -20:1:20;
cfg.grid.zgrid  = -20:1:20;
cfg.grid.unit   = 'cm';
cfg.grid.tight  = 'yes';
cfg.inwardshift = -1.5;
cfg.headmodel = din.vol;
template_grid = ft_prepare_sourcemodel(cfg);
template_grid = ft_convert_units(template_grid,'cm');

figure;
ft_plot_mesh(template_grid.pos(template_grid.inside,:));
hold on
ft_plot_vol(din.vol,  'facecolor', 'cortex', 'edgecolor', 'none');
alpha 0.5; 
camlight;

%% load atlas
matlab_dir = userpath;
pathstr = fullfile(matlab_dir(1:end-1),'fieldtrip-20160128','template','atlas','aal');
atlas_file = fullfile(pathstr,'ROI_MNI_V4.nii');

atlas = ft_read_atlas(atlas_file);
atlas = ft_convert_units(atlas,'cm');

%% select anatomical ROI
cfg = [];
cfg.atlas = atlas;
cfg.roi = {'Cerebelum_Crus2_R'};%atlas.tissuelabel;
cfg.inputcoord = 'mni';
mask = ft_volumelookup(cfg,template_grid);

%% select grid based on anatomical ROI mask
tmp = zeros(size(template_grid.inside));
tmp = logical(tmp);
% tmp = repmat(template_grid.inside,1,1);
% tmp(tmp==1) = 0;
tmp(mask) = 1;
grid_sel = template_grid;
grid_sel.inside = tmp;
 
figure;
ft_plot_mesh(template_grid.pos(template_grid.inside,:),'vertexcolor','g');
hold on;
ft_plot_mesh(grid_sel.pos(grid_sel.inside,:));