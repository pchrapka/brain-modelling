function L1cm()
% L1cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
resolution = 1;
cfg.ft_prepare_leadfield.normalize = 'no';
cfg.ft_prepare_leadfield.grid.xgrid = -6:resolution:11;
cfg.ft_prepare_leadfield.grid.ygrid = -7:resolution:6;
cfg.ft_prepare_leadfield.grid.zgrid = -1:resolution:12;
% cfg.ft_prepare_leadfield.grid.resolution = 5;
cfg.ft_prepare_leadfield.grid.unit = 'cm';

save(fullfile(srcdir,'L1cm.mat'),'cfg');

end