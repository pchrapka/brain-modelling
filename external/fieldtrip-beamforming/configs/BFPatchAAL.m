function BFPatchAAL()
% BFPatchAAL

cfg = [];
cfg.cortical_patches_name = 'aal';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end