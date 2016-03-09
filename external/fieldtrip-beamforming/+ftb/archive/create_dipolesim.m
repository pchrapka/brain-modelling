function cfg = create_dipolesim(cfg)
%
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%   cfg.stage.electrodes
%       electrode configuration name
%   cfg.stage.dipolesim
%       dipole simulation name
%
%   cfg.signal.ft_dipolesignal
%   cfg.signal.ft_dipolesimulation
%   cfg.interference.ft_dipolesignal
%   cfg.interference.ft_dipolesignal
%   cfg.ft_dipolesimulationnoise
%
%   cfg.folder
%       (optional, default = 'output/stage[number]_dipolesim/name')
%       output folder for simulation data
%   cfg.ft_dipolesimulation
%       options for ft_dipolesimulation, see ft_dipolesimulation
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

% Components
signal_components = {...
    'signal',...
    'interference',...
    'noise',...
    'all',...
    };
% Analysis functions
functions = {...
    'ft_dipolesignal',...
    'ft_dipolesimulation',...
    'ft_timelockanalysis',...
    'adjust_snr',...
    };

% Loop over signal components
for i=1:length(signal_components)
    component = signal_components{i};
    for j=1:length(functions)
        ftfunc = functions{j};
        
        % Output of ftfunc
        cfg.files.(ftfunc).(component) = fullfile(...
            cfg.folder, [ftfunc '_' component '.mat']);
    end
end

%% Create the dipole signals
% NOTE Doesn't consider multiple signals
signal_components = {...
    'signal',...
    'interference',...
    };

% Loop over signal components
for i=1:length(signal_components)
    component = signal_components{i};
    
    if ~isfield(cfg, component)
        % Skip the component if it doesn't exist
        continue;
    end
    
    if isfield(cfg.(component), 'ft_dipolesignal')
        outputfile = cfg.files.ft_dipolesignal.(component);
        
        if ~exist(outputfile, 'file') || cfg.force
            % Copy params
            cfgin = cfg.(component).ft_dipolesignal;
            
            % Simulate dipole signal
            data = ft_dipolesignal(cfgin);
            save(outputfile, 'data');
        else
            fprintf('%s: skipping ft_dipolesignal for %s, already exists\n',...
                mfilename, component);
        end
    end
end

%% Simulate the dipoles

signal_components = {...
    'signal',...
    'interference',...
    };

% Loop over signal components
for i=1:length(signal_components)
    component = signal_components{i};
    outputfile = cfg.files.ft_dipolesimulation.(component);
    
    if ~isfield(cfg, component)
        % Skip the component if it doesn't exist
        continue;
    end
    
    if ~exist(outputfile,'file') || cfg.force
        % Copy params
        cfgin = cfg.(component).ft_dipolesimulation;
        cfgin.elecfile = cfgelec.files.elec_aligned;
        cfgin.headmodel = cfghm.files.mri_headmodel;
        
        % TODO remove fiducial channels in electrode stage
        if ~isfield(cfgin, 'channel')
            % Remove fiducial channels
            elec = ftb.util.loadvar(cfgin.elecfile);
            cfgin.channel = ft_channelselection(...
                {'all','-FidNz','-FidT9','-FidT10'}, elec.label);
        end
        
        % Set up the dipole signal if it exists
        if isfield(cfg.(component), 'ft_dipolesignal')
            % Load the signal
            signal = ftb.util.loadvar(cfg.files.ft_dipolesignal.(component));
            cfgin.dip.signal = signal;
        end
        
        % Simulate dipoles
        data = ft_dipolesimulation(cfgin);
        save(outputfile, 'data');
    else
        fprintf('%s: skipping ft_dipolesimulation for %s, already exists\n',...
            mfilename, component);
    end
end

%% Simulate the noise
outputfile = cfg.files.ft_dipolesimulation.noise;
if ~isfield(cfg, 'ft_dipolesimulationnoise')
    fprintf('%s: skipping ft_dipolesimulationnoise for noise, not specified\n',...
        mfilename);
elseif ~exist(outputfile,'file') || cfg.force
    % Copy params
    cfgin = cfg.ft_dipolesimulationnoise;
    cfgin.elecfile = cfgelec.files.elec_aligned;
    cfgin.hdmfile = cfghm.files.mri_headmodel;
    
    % TODO remove fiducial channels in electrode stage
    if ~isfield(cfgin, 'channel')
        % Remove fiducial channels
        elec = ftb.util.loadvar(cfgin.elecfile);
        cfgin.channel = ft_channelselection(...
            {'all','-FidNz','-FidT9','-FidT10'}, elec.label);
    end
    
    % Simulate noise
    data = ft_dipolesimulationnoise(cfgin);
    save(outputfile, 'data');
else
    fprintf('%s: skipping ft_dipolesimulationnoise for noise, already exists\n',...
        mfilename);
end

%% Average the data
signal_components = {...
    'signal',...
    'interference',...
    'noise',...
    };

% Loop over signal components
for i=1:length(signal_components)
    component = signal_components{i};
    inputfile = cfg.files.ft_dipolesimulation.(component);
    outputfile = cfg.files.ft_timelockanalysis.(component);
    
    if ~isequal(component, 'noise') && ~isfield(cfg, component)
        % Skip the component if it doesn't exist
        continue;
    end
    
    if ~exist(inputfile, 'file')
        % Skip the component if the input file does not exist
        % Should be limited to only the noise component, if there are no
        % options for ft_dipolesimulationnoise
        if ~isequal(component, 'noise')
            error(['ftb:' mfilename],...
                'something went wrong here');
        end
        continue;
    end
    
    if ~exist(outputfile, 'file')
%         cfgin = cfg.ft_timelockanalysis;
        cfgin = [];
%         cfgin.covariance = 'yes';
%         cfgin.covariancewindow = 'all';
        cfgin.keeptrials = 'no';
        cfgin.removemean = 'yes';
        cfgin.inputfile = inputfile;
        cfgin.outputfile = outputfile;
        
%         % TODO remove fiducial channels in electrode stage
%         if ~isfield(cfgin, 'channel')
%             % Remove fiducial channels
%             elec = ftb.util.loadvar(cfgelec.files.elec_aligned);
%             cfgin.channel = ft_channelselection(...
%                 {'all','-FidNz','-FidT9','-FidT10'}, elec.label);
%         end
        
        ft_timelockanalysis(cfgin);
    else
        fprintf('%s: skipping ft_timelockanalysis for %s, already exists\n',...
            mfilename, component);
    end
end

%% Adjust signal and interference snr relative to the noise
signal_components = {...
    'signal',...
    'interference',...
    };

% Loop over signal components
for i=1:length(signal_components)
    component = signal_components{i};
    inputfile = cfg.files.ft_timelockanalysis.(component);
    noisefile = cfg.files.ft_timelockanalysis.noise;
    outputfile = cfg.files.adjust_snr.(component);
    
    if ~isfield(cfg, component)
        % Skip the component if it doesn't exist
        continue;
    end
    
    if ~exist(outputfile, 'file')
        
        if ~isfield(cfg, 'ft_dipolesimulationnoise')
            fprintf('%s: skipping adjust_snr, ft_dipolesimulationnoise not specified\n',...
                mfilename);
            % That is the snr is already adjusted, so just copy the
            % previous file
            copyfile(inputfile, outputfile);
        else
            cfgin = [];
            cfgin.snr = cfg.(component).snr;
            cfgin.inputfile = inputfile;
            cfgin.noisefile = noisefile;
            cfgin.outputfile = outputfile;
            ftb.adjust_snr(cfgin);
        end
    else
        fprintf('%s: skipping ftb.adjust_snr for %s, already exists\n',...
            mfilename, component);
    end
end


%% Sum all the components together and calculate the covariance

signal_components = {...
    'signal',...
    'interference',...
    'noise',...
    };
outputfile = cfg.files.adjust_snr.all;

% Loop over signal components
if ~exist(outputfile, 'file')
    data_all = [];
    
    % Sum all the components together
    for i=1:length(signal_components)
        component = signal_components{i};
        if isequal(component, 'noise')
            inputfile = cfg.files.ft_timelockanalysis.(component);
            % Might not exist is ft_dipolesimulationnoise is not specified
            if ~exist(inputfile, 'file')
                % Skip the component if it doesn't exist
                continue;
            end
        else
            if ~isfield(cfg, component)
                % Skip the component if it doesn't exist
                continue;
            end
            inputfile = cfg.files.adjust_snr.(component);
        end
        
        % Load the snr adjusted component data
        data = ftb.util.loadvar(inputfile);
        
        % Sum all the components together
        if isempty(data_all)
            data_all = data;
        else
            data_all.avg = data_all.avg + data.avg;
        end
        
    end
    
    % Calculate the covariance
    cfgin = [];
    cfgin.covariance = 'yes';
    cfgin.covariancewindow = 'all';
    cfgin.keeptrials = 'no';
    cfgin.removemean = 'no';
%     cfgin.inputfile = inputfile;
    cfgin.outputfile = outputfile;
    
    ft_timelockanalysis(cfgin, data_all);
else
    fprintf('%s: skipping ft_timelockanalysis for all components, already exists\n',...
        mfilename);
end

%% Save the config file
ftb.save_config(cfg);

end