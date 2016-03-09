function E32()
% E32

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-32.sfp';

save(fullfile(srcdir,'E32.mat'),'cfg');

end