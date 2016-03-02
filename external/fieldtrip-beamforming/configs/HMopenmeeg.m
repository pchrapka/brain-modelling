function HMopenmeeg()
% HMopenmeeg

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.ft_prepare_headmodel.method = 'openmeeg';

save(fullfile(srcdir,'HMopenmeeg.mat'),'cfg');

end