function cfg = setup_folder(cfg)
%setup_folder sets up the output folder for the current stage
%
%   Input
%   -----
%   default mode
%   cfg.stage.full
%       full name of the stage, output of get_stage
%
%   custom mode
%   cfg.folder
%       (optional) output folder for head model files
%
%   Output
%   ------
%   cfg.folder
%       folder created for head model files
%
%   See also ftb.get_stage

% Check if a folder is specified
if ~isfield(cfg, 'folder') || isempty(cfg.folder)
    % Check if stage has been populated
    if ~isfield(cfg, 'stage') && ~isfield(cfg.stage, 'folder')
        cfg = ftb.get_stage(cfg);
    end
    cfg.folder = fullfile('output', cfg.stage.folder, cfg.stage.full);
end

% Set up the output folder
if ~exist(cfg.folder, 'dir')
    mkdir(cfg.folder);
end

end