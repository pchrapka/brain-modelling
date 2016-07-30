function E128_cm()
% E128_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-128.sfp';
cfg.units = 'cm';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end