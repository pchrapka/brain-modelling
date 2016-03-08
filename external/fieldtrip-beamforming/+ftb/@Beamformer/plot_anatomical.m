function plot_anatomical(obj)
%PLOT_ANATOMICAL plots source power on anatomical image

% load source analysis
source = ftb.util.loadvar(obj.sourceanalysis);

% % load the head model
% cfgtmp = ftb.get_stage(cfg, 'headmodel');
% cfghm = ftb.load_config(cfgtmp.stage.full);
% vol = ftb.util.loadvar(cfghm.files.mri_headmodel);

% if isfield(cfg, 'contrast')
%     % Load noise source
%     cfgcopy = cfg;
%     cfgcopy.stage.dipolesim = cfg.contrast;
%     cfgtmp = ftb.get_stage(cfgcopy);
%     cfgnoise = ftb.load_config(cfgtmp.stage.full);
%     source_noise = ftb.util.loadvar(cfgnoise.files.ft_sourceanalysis.all);
% end

% get MRI object
mriObj = obj.get_dep('ftb.MRI');

cfgin = [];
mri = ftb.util.loadvar(mriObj.mri_mat);
resliced = ft_volumereslice(cfgin, mri);

% Take neural activity index
% NOTE doesn't seem to help
sourcenai = source;
% if exist('source_noise', 'var')
%     sourcenai.avg.pow = source.avg.pow ./ source_noise.avg.pow - 1;
% end
% %sourcenai.avg.pow = source.avg.pow ./ source.avg.noise;

cfgin = [];
cfgin.parameter = 'pow';
interp = ft_sourceinterpolate(cfgin, sourcenai, resliced);

plot_log = true;
if plot_log
    interp.pow = db(interp.pow,'power');
end

cfgin = [];
cfgin.method = 'slice';
%             cfgin.method = 'ortho';
cfgin.funparameter = 'pow';
ft_sourceplot(cfgin, interp);

end