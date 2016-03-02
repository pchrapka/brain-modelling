% HMbemcp_cm

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
cfg.ft_prepare_headmodel.method = 'bemcp';
cfg.units = 'cm';

save('HMbemcp-cm.mat','cfg');

cd(curdir);