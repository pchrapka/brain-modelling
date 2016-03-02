function obj = create_test_leadfield()
cfg = [];

resolution = 5;
cfg.ft_prepare_leadfield.grid.xgrid = -60:resolution:110;
cfg.ft_prepare_leadfield.grid.ygrid = -70:resolution:60;
cfg.ft_prepare_leadfield.grid.zgrid = -10:resolution:120;
% cfg.ft_prepare_leadfield.grid.resolution = 5;
cfg.ft_prepare_leadfield.grid.unit = 'mm';

obj = ftb.Leadfield(cfg, 'Test5mm');

end