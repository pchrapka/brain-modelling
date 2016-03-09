function E256()
% E256

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-256.sfp';

save(fullfile(srcdir,'E256.mat'),'cfg');

end