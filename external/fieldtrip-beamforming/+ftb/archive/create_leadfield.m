function cfg = create_leadfield(cfg)
%
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%   cfg.stage.electrodes
%       electrode configuration name
%   cfg.stage.leadfield
%       lead field name
%
%   cfg.folder
%       (optional, default = 'output/stage2_leadfield/name')
%       output folder for head model data
%   cfg.ft_prepare_leadfield
%       options for ft_prepare_leadfield, see ft_prepare_leadfield
%
%   cfg.force
%       force recomputation, default = false
%
%   Output
%   ------
%   cfg.files

if ~isfield(cfg, 'force'), cfg.force = false; end

% Populate the stage information
cfg = ftb.get_stage(cfg);

% Set up the output folder
cfg = ftb.setup_folder(cfg);

%% Load head model config
cfgtmp = ftb.get_stage(cfg, 'headmodel');
cfghm = ftb.load_config(cfgtmp.stage.full);
cfgtmp = ftb.get_stage(cfg, 'electrodes');
cfgelec = ftb.load_config(cfgtmp.stage.full);

%% Set up file names
cfg.files.leadfield = fullfile(cfg.folder, 'leadfield.mat');

%% Compute leadfield

if isfield(cfg, 'ft_prepare_sourcemodel')
    cfgin = cfg.ft_prepare_sourcemodel;
    cfgin.vol = ftb.util.loadvar(cfghm.files.mri_headmodel);
%     cfgin.hdmfile = cfghm.files.mri_headmodel;
    % Set up the source model
    grid = ft_prepare_sourcemodel(cfgin);
    % Add to leadfield config
    cfg.ft_prepare_leadfield.grid = grid;
    % NOTE 
    % Doens't work, volume surface defaults to skin, no option for
    % ft_prepare_sourcemodel to change it
end

cfgin = cfg.ft_prepare_leadfield;
cfgin.elecfile = cfgelec.files.elec_aligned;
cfgin.hdmfile = cfghm.files.mri_headmodel;
if ~exist(cfg.files.leadfield,'file') || cfg.force
    
    % TODO remove fiducial channels in electrode stage
    if ~isfield(cfgin, 'channel')
        % Remove fiducial channels
        elec = ftb.util.loadvar(cfgin.elecfile);
        cfgin.channel = ft_channelselection(...
            {'all','-FidNz','-FidT9','-FidT10'}, elec.label);
    end
    
    % Compute leadfield
    leadfield = ft_prepare_leadfield(cfgin);
    save(cfg.files.leadfield, 'leadfield');
else
    fprintf('%s: skipping ft_prepare_leadfield, already exists\n',mfilename);
end

%% Save the config file
ftb.save_config(cfg);

end