function HMbemcp()
% HMbemcp

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.ft_prepare_headmodel.method = 'bemcp';

save(fullfile(srcdir,'HMbemcp.mat'),'cfg');

end