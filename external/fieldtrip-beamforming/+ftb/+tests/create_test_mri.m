function obj = create_test_mri()
cfg = [];

% Processing options
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.method = 'projectmesh';
cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.numvertices = [2000, 1500, 1000];
% MRI data
cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');

obj = ftb.MRI(cfg, 'TestMRI');
end