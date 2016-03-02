% L5mm

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
resolution = 5;
cfg.ft_prepare_leadfield.grid.xgrid = -60:resolution:110;
cfg.ft_prepare_leadfield.grid.ygrid = -70:resolution:60;
cfg.ft_prepare_leadfield.grid.zgrid = -10:resolution:120;
% cfg.ft_prepare_leadfield.grid.resolution = 5;
cfg.ft_prepare_leadfield.grid.unit = 'mm';

save('L5mm.mat','cfg');

cd(curdir);