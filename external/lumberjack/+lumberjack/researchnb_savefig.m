function researchnb_savefig(filename)
%RESEARCHNB_SAVEFIG Saves the current figure to my research notebook
%   RESEARCHNB_SAVEFIG(filename) Saves the current figure to my research notebook
%
%   Input
%   -----
%   filename (string)
%       file name for image

cfg = [];
cfg.out_dir = fullfile('/home','phil','projects','research-notebook','img');
cfg.file_name = [datestr(now, 'yyyy-mm-dd') '-' filename];

set(gcf, 'Color', 'w');
lumberjack.save_figure(cfg);

end