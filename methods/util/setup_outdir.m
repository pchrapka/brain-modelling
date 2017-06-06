function outdir = setup_outdir(basedir,outdir)
% setup_outdir sets up the output directory
if isempty(basedir)
    basedir = pwd;
else
    [expdir,~,ext] = fileparts(basedir);
    if ~isempty(ext)
        basedir = expdir;
    end
end

% set up output directory
outdir = fullfile(basedir,outdir);
if ~exist(outdir,'dir')
    mkdir(outdir);
end
end