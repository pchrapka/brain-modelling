%% exp07_mqrd_lsl_beamform_eeg
% Goal: 
%   Apply MQRD-LSL on beamformed real EEG data

close all;

doplot = true;

datadir = '/home/phil/projects/data-coma-richard/BC-HC-YOUTH/Cleaned';

% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

%% Set up beamformer analysis
% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-fb');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

analysis = ftb.AnalysisBeamformer(out_folder);

%% Create and process MRI and HM

% MRI
params_mri = 'MRIS01.mat';
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = 'HMdipoli-cm.mat';
hm = ftb.Headmodel(params_hm,'dipoli-cm');

% Add steps
analysis.add(m);
analysis.add(hm);

% Process pipeline
analysis.init();
analysis.process();

%% Create and process the electrodes

% Electrodes
params_e = [];
params_e.elec_orig = fullfile(datadir,'BC.HC.YOUTH.P020-10834.sfp');
% [pos,names] = m.get_mri_fiducials();
% % replace NAS with NZ
% for i=1:length(names)
%     if isequal(names{i},'NAS')
%         names{i} = 'NZ';
%         break;
%     end
% end
% 
% % create a structure similar to a template set of electrodes
% fit = [];
% fid.chanpos = pos;          % ctf-coordinates of fiducials
% fid.label = upper(names);   % same as in elec
% fid.unit = 'mm';            % same units as mri
% 
% % Alignment
% params_e.ft_electroderealign = [];
% params_e.ft_electroderealign.method = 'fiducial';
% params_e.ft_electroderealign.template = fid;
% % labels of fiducials in fid and in elec
% params_e.ft_electroderealign.fiducial = upper(names);
[~,name_e,~] = fileparts(params_e.elec_orig);
name_e = strrep(name_e,'BC.HC.YOUTH.','');

e = ftb.Electrodes(params_e,name_e);
e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
analysis.add(e);
e.force = false;

% Process pipeline
analysis.init();
analysis.process();
e.force = false;

% Manually rename channel
elec = ftb.util.loadvar(e.elec_aligned);
idx = cellfun(@(x) isequal(x,'Afz'),elec.label);
elec.label{idx} = 'AFz';
save(e.elec_aligned,'elec');

e.plot({'scalp','fiducials','electrodes-aligned','electrodes-labels'});


%% Create the rest of the pipeline

% Create custom configs
% DSarind_cm();
BFlcmv_exp07();

% Leadfield
% params_lf = [];
% resolution = 1;
% params_lf.ft_prepare_leadfield.normalize = 'yes';
% params_lf.ft_prepare_leadfield.grid.xgrid = -6:resolution:11;
% params_lf.ft_prepare_leadfield.grid.ygrid = -7:resolution:6;
% params_lf.ft_prepare_leadfield.grid.zgrid = -1:resolution:12;
% % params_lf.ft_prepare_leadfield.grid.resolution = 5;
% params_lf.ft_prepare_leadfield.grid.unit = 'cm';
% elec = ftb.util.loadvar(e.elec_aligned);
% params_lf.ft_prepare_leadfield.channel = ft_channelselection(...
%     {'all','-NZ','-LPA','-RPA','-Afz'}, elec.label);
params_lf = 'L1cm-norm.mat';
lf = ftb.Leadfield(params_lf,'1cm-norm-custom');
analysis.add(lf);
lf.force = true;

% EEG
datafile = 'BC.HC.YOUTH.P020-10834-MMNf.eeg';
params_eeg.ft_definetrial = [];
params_eeg.ft_definetrial.dataset = fullfile(datadir,datafile);
% use default function
params_eeg.ft_definetrial.trialdef.eventtype = 'Stimulus';
params_eeg.ft_definetrial.trialdef.eventvalue = {'S 11'};
params_eeg.ft_definetrial.trialdef.prestim = 0.4; % in seconds
params_eeg.ft_definetrial.trialdef.poststim = 1; % in seconds

% assuming data was already processed
params_eeg.ft_preprocessing.method = 'trial';
params_eeg.ft_preprocessing.continuous = 'no';
params_eeg.ft_preprocessing.detrend = 'no';
params_eeg.ft_preprocessing.demean = 'no';
params_eeg.ft_preprocessing.channel = 'EEG';

params_eeg.ft_timelockanalysis.covariance = 'yes';
params_eeg.ft_timelockanalysis.covariancewindow = 'all';
params_eeg.ft_timelockanalysis.keeptrials = 'no';
params_eeg.ft_timelockanalysis.removemean = 'yes';

name_eeg = strrep(datafile,'BC.HC.YOUTH.','');
name_eeg = strrep(name_eeg,'.eeg','');
eeg = ftb.EEG(params_eeg,name_eeg);
analysis.add(eeg);

% Beamformer
params_bf = 'BFlcmv-exp07.mat';
bf = ftb.Beamformer(params_bf,'lcmv-exp07');
analysis.add(bf);

%% Process pipeline
analysis.init();
analysis.process();

% FIXME NOT WORKING!!!
% TODO Plot timelocked data

%% Plot all results
figure;
bf.plot({'brain','skull','scalp','fiducials'});
figure;
bf.plot_scatter([]);
bf.plot_anatomical();

%% Extract sources of interest (SOI)
max_sources = 10;
moments = moments_max(bf.sourceanalysis, 'N', max_sources);
%X = moments(1:max_sources);
%convert moments to signals, how do i get a 1D signal from moment
% for now use 1st component
component = 1;

% get component from moments
nsamples = size(moments{1},2);
X = zeros(max_sources,nsamples);
for i=1:max_sources
    X(i,:) = moments{i}(component,:);
end

% Normalize variance of each channel to unit variance
X_norm = X./repmat(std(X,0,2),1,nsamples);

if ~isequal(size(X), [max_sources nsamples])
    disp(size(X))
    error('X is bad size');
end

if doplot
    
end

%% LSL params
nchannels = max_sources;
order = 4;

%% Estimate the Reflection coefficients using the MQRD-LSL algorithm
i=1;
lattice = [];

% nchannels from above
% order from above
lambda = 0.99;
verbose = 1;
% lattice(i).alg = MQRDLSL1(nchannels,order,lambda);
lattice(i).alg = MQRDLSL2(nchannels,order,lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',nchannels,order,lambda);
i = i+1;

% estimate the reflection coefficients
lattice = estimate_reflection_coefs(lattice, X_norm, verbose);

%% Compare true and estimated
Kest_stationary = zeros(order,nchannels,nchannels);

% TODO get true values

% plot
if doplot
    for ch1=1:nchannels
        for ch2=ch1:nchannels
            figure;
            k_true = repmat(squeeze(Kest_stationary(:,ch1,ch2)),1,nsamples);
            plot_reflection_coefs(lattice, k_true, nsamples, ch1, ch2);
        end
    end
end