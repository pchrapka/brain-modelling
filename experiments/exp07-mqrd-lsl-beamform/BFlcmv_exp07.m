function BFlcmv_exp07()
% BFlcmv_exp07

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';
%cfg.ft_sourceanalysis.lcmv.projectnoise = 'yes';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end