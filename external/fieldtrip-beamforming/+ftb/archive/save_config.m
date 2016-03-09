function save_config(cfg)

outdir = fullfile('.ftb', 'config');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

save(fullfile(outdir, [cfg.stage.full '.mat']), 'cfg');

end