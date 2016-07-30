function L1cm_norm_tight()
% L1cm_norm_tight

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.ft_prepare_leadfield.resolution = 1;
cfg.ft_prepare_leadfield.normalize = 'yes';
cfg.ft_prepare_leadfield.tight = 'yes';
cfg.ft_prepare_leadfield.grid.resolution = 1;
cfg.ft_prepare_leadfield.grid.unit = 'cm';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end