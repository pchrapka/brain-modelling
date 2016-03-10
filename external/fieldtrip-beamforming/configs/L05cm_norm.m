function L05cm_norm()
% L05cm_norm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
resolution = 0.5;
cfg.ft_prepare_leadfield.normalize = 'yes';
cfg.ft_prepare_leadfield.grid.xgrid = -6:resolution:11;
cfg.ft_prepare_leadfield.grid.ygrid = -7:resolution:6;
cfg.ft_prepare_leadfield.grid.zgrid = -1:resolution:12;
% cfg.ft_prepare_leadfield.grid.resolution = 5;
cfg.ft_prepare_leadfield.grid.unit = 'cm';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end