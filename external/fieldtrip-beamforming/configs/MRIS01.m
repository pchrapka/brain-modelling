function MRIS01()
% MRIS01

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
% Processing options
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.method = 'projectmesh';
cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.numvertices = [2000, 2000, 1000];
% NOTE [3000, 2000, 1000] gives me an error: Mesh is self intersecting
% MRI data
cfg.mri_data = fullfile(srcdir,'..','anatomy','Subject01','Subject01.mri');

save(fullfile(srcdir,'MRIS01.mat'),'cfg');

end