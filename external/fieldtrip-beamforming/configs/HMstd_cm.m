function HMstd_cm()
% HMstd_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.load_files = {...
    {'mri_headmodel', 'standard_bem.mat'},...
    };

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end