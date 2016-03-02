% BFlcmv

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

cfg = [];
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'no';
%cfg.ft_sourceanalysis.lcmv.projectnoise = 'yes';

save('BFlcmv.mat','cfg');

cd(curdir);