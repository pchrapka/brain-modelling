function BFPatchAAL13()
% BFPatchAAL13

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.cortical_patches_name = 'aal-coarse-13';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end