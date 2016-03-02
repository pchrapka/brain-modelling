function obj = create_test_elec()
cfg = [];

cfg.elec_orig = 'GSN-HydroCel-128.sfp';

obj = ftb.Electrodes(cfg, 'Test128');

end