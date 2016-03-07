%% exp07_mqrd_lsl_beamform
% Goal: 
%   Apply MQRD-LSL on beamformed EEG data

close all;

doplot = true;

% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

%% Create analysis step objects

% Create custom configs
DSarind_cm();
BFlcmv_exp07();

% MRI
params_mri = 'MRIS01.mat';
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = 'HMdipoli-cm.mat';
hm = ftb.Headmodel(params_hm,'dipoli-cm');

params_e = 'E128-cm.mat';
e = ftb.Electrodes(params_e,'128-cm');

params_lf = 'L1cm-norm.mat';
lf = ftb.Leadfield(params_lf,'1cm-norm');

params_dsim = 'DSarind-cm.mat';
dsim = ftb.DipoleSim(params_dsim,'arind-cm');
 
params_bf = 'BFlcmv-exp07.mat';
bf = ftb.Beamformer(params_bf,'lcmv-exp07');

%% Set up beamformer analysis
% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-fb');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

analysis = ftb.AnalysisBeamformer(out_folder);

%% Add analysis steps
analysis.add(m);
analysis.add(hm);
analysis.add(e);
analysis.add(lf);
analysis.add(dsim);
dsim.force = false;
analysis.add(bf);

%% Process pipeline
analysis.init();
analysis.process();


%% Plot all results
figure;
bf.plot({'brain','skull','scalp','fiducials','dipole'});
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