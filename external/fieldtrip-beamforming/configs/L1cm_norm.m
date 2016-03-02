% L1cm_norm

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
resolution = 1;
cfg.ft_prepare_leadfield.normalize = 'yes';
cfg.ft_prepare_leadfield.grid.xgrid = -6:resolution:11;
cfg.ft_prepare_leadfield.grid.ygrid = -7:resolution:6;
cfg.ft_prepare_leadfield.grid.zgrid = -1:resolution:12;
% cfg.ft_prepare_leadfield.grid.resolution = 5;
cfg.ft_prepare_leadfield.grid.unit = 'cm';

save('L1cm-norm.mat','cfg');

cd(curdir);