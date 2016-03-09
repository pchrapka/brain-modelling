function obj = create_test_hm()
cfg = [];

cfg.ft_prepare_headmodel.method = 'bemcp';

obj = ftb.Headmodel(cfg, 'TestHM');
end