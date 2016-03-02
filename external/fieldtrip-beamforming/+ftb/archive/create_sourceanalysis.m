function cfg = create_sourceanalysis(cfg)
%
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%   cfg.stage.leadfield
%       lead field name
%   cfg.stage.electrodes
%       electrode configuration name
%   cfg.stage.dipolesim
%       dipole simulation name
%
%   cfg.folder
%       (optional, default = 'output/stage1_headmodel/shortname')
%       output folder for head model data
%   cfg.ft_sourceanalysis
%       options for ft_sourceanalysis, see ft_sourceanalysis
%
%   Output
%   ------
%   cfg.files

debug = false;

if ~isfield(cfg, 'force'), cfg.force = false; end

% Populate the stage information
cfg = ftb.get_stage(cfg);

% Set up the output folder
cfg = ftb.setup_folder(cfg);

%% Load stage configs
cfgtmp = ftb.get_stage(cfg, 'headmodel');
cfghm = ftb.load_config(cfgtmp.stage.full);
cfgtmp = ftb.get_stage(cfg, 'electrodes');
cfgelec = ftb.load_config(cfgtmp.stage.full);
cfgtmp = ftb.get_stage(cfg, 'leadfield');
cfglf = ftb.load_config(cfgtmp.stage.full);
cfgtmp = ftb.get_stage(cfg, 'dipolesim');
cfgdp = ftb.load_config(cfgtmp.stage.full);

%% Set up file names
component = 'all';
cfg.files.ft_sourceanalysis.all = fullfile(...
            cfg.folder, ['ft_sourceanalysis_' component '.mat']);

%% Compute source analysis
inputfile = cfgdp.files.adjust_snr.all;
outputfile = cfg.files.ft_sourceanalysis.all;
if ~exist(outputfile,'file') || cfg.force
    % Copy params
    cfgin = cfg.ft_sourceanalysis;
    
    % Set up head model files
    grid = ftb.util.loadvar(cfglf.files.leadfield);
    if isfield(cfgin, 'grid')
        % Copy the filters if they're specified
        if isfield(cfgin.grid, 'filter')
            grid.filter = cfgin.grid.filter;
        end
    end
    cfgin.grid = grid;
    cfgin.elecfile = cfgelec.files.elec_aligned;
    cfgin.headmodel = cfghm.files.mri_headmodel;
    
    cfgin.inputfile = inputfile;
    cfgin.outputfile = outputfile;
    
    % Source analysis
    ft_sourceanalysis(cfgin);
%     data = ft_sourceanalysis(cfgin);
%     save(outputfile, 'data');
else
    fprintf('%s: skipping ft_sourceanalysis, already exists\n',...
        mfilename);
end

%% Save the config file
ftb.save_config(cfg);

end