% check_data
% Load data produced by different stages

cfgtmp = ftb.get_stage(cfg,'headmodel');
cfghm = ftb.load_config(cfgtmp.stage.full);
hm = ftb.util.loadvar(cfghm.files.mri_headmodel);

cfgtmp = ftb.get_stage(cfg,'beamformer');
cfgsource = ftb.load_config(cfgtmp.stage.full);
source = ftb.util.loadvar(cfgsource.files.ft_sourceanalysis.all);

cfgtmp = ftb.get_stage(cfg,'dipolesim');
cfgdp = ftb.load_config(cfgtmp.stage.full);
sim = ftb.util.loadvar(cfgdp.files.ft_dipolesimulation.signal);

cfgtmp = ftb.get_stage(cfg,'leadfield');
cfglf = ftb.load_config(cfgtmp.stage.full);
leadfield = ftb.util.loadvar(cfglf.files.leadfield);