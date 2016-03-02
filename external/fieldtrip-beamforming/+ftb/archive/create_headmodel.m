function cfg = create_headmodel(cfg)
%
%   Input
%   -----
%   cfg.mri_data
%       MRI file for head model
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%
%   cfg.folder
%       (optional, default = 'output/stage1_headmodel/shortname')
%       output folder for head model data
%   cfg.ft_volumesegment
%       options for ft_volumesegment, see ft_volumesegment
%   cfg.ft_prepare_headmodel
%       options for ft_prepare_headmodel, see ft_prepare_headmodel
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

%% Set up file names
files = [];
files.mri = cfg.mri_data;

% MRI data specific
[mri_folder, mri_name, ~] = fileparts(cfg.mri_data);
files.mri_mat = fullfile(mri_folder, [mri_name '_mri.mat']);
files.mri_segmented = fullfile(mri_folder, [mri_name '_mri_segmented.mat']);

% Method specific
files.mri_mesh = fullfile(cfg.folder, 'mri_mesh.mat');
files.mri_headmodel = fullfile(...
    cfg.folder, ['mri_vol_' cfg.ft_prepare_headmodel.method '.mat']);

%% Segment the MRI

% Read the MRI
cfgin = [];
cfgin.inputfile = files.mri;
cfgin.outputfile = files.mri_mat;
if ~exist(cfgin.outputfile,'file')
    ft_read_mri_mat(cfgin);
else
    fprintf('%s: skipping ft_read_mri_mat, already exists\n',mfilename);
end

% Segment the MRI data
cfgin = cfg.ft_volumesegment;
cfgin.inputfile = files.mri_mat;
cfgin.outputfile = files.mri_segmented;
if ~exist(cfgin.outputfile,'file')
    ft_volumesegment(cfgin);
else
    fprintf('%s: skipping ft_volumesegment, already exists\n',mfilename);
end

% Prep the mesh
cfgin = cfg.ft_prepare_mesh;
cfgin.inputfile = files.mri_segmented;
% cfgin.outputfile = files.mri_mesh; % forbidden
outputfile = files.mri_mesh;
if ~exist(outputfile,'file')
    mesh = ft_prepare_mesh(cfgin);
    save(outputfile, 'mesh');
    
    % Check meshes
    if debug
        for i=1:length(cfgin.tissue)
            figure;
            ft_plot_mesh(mesh(i),'facecolor','none'); %brain
            title(cfgin.tissue{i});
        end
    end
else
    fprintf('%s: skipping ft_prepare_mesh, already exists\n',mfilename);
end

%% Create the head model from the segmented data
cfgin = cfg.ft_prepare_headmodel;
inputfile = files.mri_mesh;
outputfile = files.mri_headmodel;
if ~exist(outputfile, 'file')
    data = ftb.util.loadvar(inputfile);
    vol = ft_prepare_headmodel(cfgin, data);
    save(outputfile, 'vol');
else
    fprintf('%s: skipping ft_prepare_headmodel, already exists\n',mfilename);
end

%% Copy file names to the config
cfg.files = files;

%% Save the config
ftb.save_config(cfg);

end