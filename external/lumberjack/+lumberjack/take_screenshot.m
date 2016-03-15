function take_screenshot(cfg)
% Takes a screenshot using gnome-screenshot
%   cfg.img_dir
%   cfg.filename

% Create the folder
if ~exist(cfg.img_dir, 'dir');
    mkdir(cfg.img_dir);
end

fullfilename = fullfile(cfg.img_dir, cfg.filename);

% Create the command
command = ['gnome-screenshot -f ' fullfilename];
% Take the screenshot
system(command);

end