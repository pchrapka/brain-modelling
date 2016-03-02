function L10mm_norm()
% L10mm_norm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
resolution = 10;
cfg.ft_prepare_leadfield.normalize = 'yes';
cfg.ft_prepare_leadfield.grid.xgrid = -60:resolution:110;
cfg.ft_prepare_leadfield.grid.ygrid = -70:resolution:60;
cfg.ft_prepare_leadfield.grid.zgrid = -10:resolution:120;
% cfg.ft_prepare_leadfield.grid.resolution = 5;
cfg.ft_prepare_leadfield.grid.unit = 'mm';

save(fullfile(srcdir,'L10mm-norm.mat'),'cfg');

end