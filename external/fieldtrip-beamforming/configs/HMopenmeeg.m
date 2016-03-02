% HMopenmeeg

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
cfg.ft_prepare_headmodel.method = 'openmeeg';

save('HMopenmeeg.mat','cfg');

cd(curdir);