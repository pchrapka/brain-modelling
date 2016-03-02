% E128_cm

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-128.sfp';
cfg.units = 'cm';

save('E128-cm.mat','cfg');

cd(curdir);