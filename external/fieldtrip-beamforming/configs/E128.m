% E128

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-128.sfp';

save('E128.mat','cfg');

cd(curdir);