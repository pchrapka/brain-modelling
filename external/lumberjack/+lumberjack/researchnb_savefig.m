function researchnb_savefig(name)
% RESEARCHNB_SAVEFIG Saves the current figure to my research notebook
%
%   name
%       file name

cfg = [];
cfg.out_dir = fullfile('/home','phil','projects','research-notebook','img');
cfg.file_name = [datestr(now, 'yyyy-mm-dd') '-' name];

set(gcf, 'Color', 'w');
lumberjack.save_figure(cfg);

end