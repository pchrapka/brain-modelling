function E128()
% E128

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-128.sfp';

save(fullfile(srcdir,'E128.mat'),'cfg');

end