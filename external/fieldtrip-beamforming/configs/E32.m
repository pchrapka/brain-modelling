% E32

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-32.sfp';

save('E32.mat','cfg');

cd(curdir);