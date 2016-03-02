function BFlcmv()
% BFlcmv

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'no';
%cfg.ft_sourceanalysis.lcmv.projectnoise = 'yes';

save(fullfile(srcdir,'BFlcmv.mat'),'cfg');

end