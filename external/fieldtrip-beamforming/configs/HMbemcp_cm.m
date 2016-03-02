function HMbemcp_cm()
% HMbemcp_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.ft_prepare_headmodel.method = 'bemcp';
cfg.units = 'cm';

save(fullfile(srcdir,'HMbemcp-cm.mat'),'cfg');

end