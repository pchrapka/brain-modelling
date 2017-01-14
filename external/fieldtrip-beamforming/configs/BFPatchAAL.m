function BFPatchAAL()
% BFPatchAAL

cfg = [];
cfg.cortical_patches_name = 'aal';
cfg.compute_lcmv_patch_filters = {'mode','single'};
cfg.ft_sourceanalysis.rawtrial = 'yes';
% cfg.ft_sourceanalysis.keeptrial = 'yes'; % not sure
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end