% MRIS01

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
% Processing options
cfg.ft_volumesegment.output = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.method = 'projectmesh';
cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
cfg.ft_prepare_mesh.numvertices = [2000, 2000, 1000];
% NOTE [3000, 2000, 1000] gives me an error: Mesh is self intersecting
% MRI data
cfg.mri_data = fullfile(srcdir,'..','anatomy','Subject01','Subject01.mri');

save('MRIS01.mat','cfg');

cd(curdir);