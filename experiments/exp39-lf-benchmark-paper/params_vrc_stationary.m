%% params_vrc_stationary

%% set options
nsims = 20;
nchannels = 10;

norder = 8;
verbosity = 0;

gen_params = {...
    'vrc-full-coupling-rnd',nchannels,...
    'version','exp39'};
% each channel is a sparse VRC process
% there is a certain level of coupling sparsity
% there is at least one coefficient in the max order specified
nsamples = 2000;
gen_config_params = {...
    'order',norder,...
    'nsamples', nsamples,...
    'channel_sparsity', 0.4,...
    'coupling_sparsity', 0.1};

% var_gen = VARGenerator(gen_params{:});
% var_gen.plot();