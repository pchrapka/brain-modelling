function HMopenmeeg_cm()
% HMopenmeeg_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.ft_prepare_headmodel.method = 'openmeeg';
cfg.units = 'cm';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end