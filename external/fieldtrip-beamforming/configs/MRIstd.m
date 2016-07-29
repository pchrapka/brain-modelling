function MRIstd()
% MRIstd

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.load_files = {...
    {'mri_mat', 'standard_mri.mat'},...
    {'mri_segmented', 'standard_seg.mat'},...
    {'mri_mesh', 'MRIfake.mat'},...
    };

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end