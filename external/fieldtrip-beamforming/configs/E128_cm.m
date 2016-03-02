function E128_cm()
% E128_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-128.sfp';
cfg.units = 'cm';

save(fullfile(srcdir,'E128-cm.mat'),'cfg');

end