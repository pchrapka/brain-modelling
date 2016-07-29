function MRIfake()
% MRIfake

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
cfg.fake = true;

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end