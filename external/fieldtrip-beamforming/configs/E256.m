% E256

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
% Processing options
cfg.elec_orig = 'GSN-HydroCel-256.sfp';

save('E256.mat','cfg');

cd(curdir);