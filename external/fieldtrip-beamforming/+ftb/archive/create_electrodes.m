function cfg = create_electrodes(cfg)
% create_electrodes adds electrodes to a head model. includes automated
% alignment of electrodes. it aligns the fiducials first, then asks if more
% manual alignment is necessary.
%
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%   cfg.stage.electrodes
%       electrode configuration name
%
%   cfg.elec_orig
%       electrode location file
%
%   cfg.folder
%       output folder for head model data
%   cfg.files
%       output files from create_headmodel
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

%% Set up file names
cfg.files.elec_orig = cfg.elec_orig;
cfg.files.elec = fullfile(cfg.folder, 'elec.mat');
cfg.files.elec_aligned = fullfile(cfg.folder, 'elec_aligned.mat');

% Save the config
ftb.save_config(cfg);

% Check if we're setting up a head model from scratch
if exist(cfg.files.elec_aligned, 'file') && ~cfg.force
    % Return if it already exists
    fprintf('%s: skipping %s, already exists\n', mfilename, mfilename);
    return
end

%% Load electrode data
if ~exist(cfg.files.elec, 'file')
    elec = ft_read_sens(cfg.files.elec_orig);
    % Ensure electrode coordinates are in mm
    elec = ft_convert_units(elec, 'mm'); % should be the same unit as MRI
    % Save
    save(cfg.files.elec, 'elec');
else
    fprintf('%s: skipping ft_read_sens, already exists\n',mfilename);
end

%% Automatic alignment
% Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
cfgin = [];
cfgin.type = 'fiducial';
cfgin.files = cfg.files;
cfgin.stage = cfg.stage;
cfgin.outputfile = cfg.files.elec_aligned;
ftb.align_electrodes(cfgin);

%% Visualization - check alignment
h = figure;
cfgin = [];
cfgin.stage = cfg.stage;
cfgin.elements = {'electrodes', 'scalp'};
ftb.vis_headmodel_elements(cfgin);

%% Interactive alignment
prompt = 'How''s it looking? Need manual alignment? (Y/n)';
response = input(prompt, 's');
if isequal(response, 'Y')
    close(h);
    % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
    cfgin = [];
    cfgin.type = 'interactive';
    cfgin.files = cfg.files;
    cfgin.stage = cfg.stage;
    % Use the automatically aligned file
    cfgin.files.elec = cfg.files.elec_aligned;
    cfgin.outputfile = cfg.files.elec_aligned;
    ftb.align_electrodes(cfgin);
end

%% Visualization - check alignment
h = figure;
cfgin = [];
cfgin.stage = cfg.stage;
cfgin.elements = {'electrodes', 'scalp'};
ftb.vis_headmodel_elements(cfgin);

%% Save the config
ftb.save_config(cfg);

end