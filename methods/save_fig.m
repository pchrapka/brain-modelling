function save_fig(cfg, filename, save_flag)
%SAVE_FIG saves figure, based on flag
%   SAVE_FIG(CFG, FILENAME, SAVE_FLAG) saves figure, based on flag
%
%   Input
%   -----
%   cfg (struct)
%       configuration to lumberjack.save_figure, requires only out_dir
%       field
%   filename (string)
%       specific filename for figure appended to date string
%   save_flag (boolean)
%       toggle actual saving

% check if we're saving
if save_flag
    % add file name
    cfg.file_name = [datestr(now, 'yyyy-mm-dd') '-' filename];
    
    % change background color
    set(gcf, 'Color', 'w');
    % save
    lumberjack.save_figure(cfg);
end

end