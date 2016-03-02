% HMbemcp

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
cfg.ft_prepare_headmodel.method = 'bemcp';

save('HMbemcp.mat','cfg');

cd(curdir);