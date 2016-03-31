function BFPatchAAL()
% BFPatchAAL

[srcdir,~,~] = fileparts(mfilename('fullpath'));

% Set up an atlas
matlab_dir = userpath;
pathstr = fullfile(matlab_dir(1:end-1),'fieldtrip-20160128','template','atlas','aal');
atlas_file = fullfile(pathstr,'ROI_MNI_V4.nii');

cfg = [];
cfg.atlas_file = atlas_file;
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end