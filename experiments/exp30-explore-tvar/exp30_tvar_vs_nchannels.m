%% exp30_tvar_vs_nchannels

%% set options
nsims = 20;
channels = [2 4 6 8 10 12 14 16];
% channels = [2 4];
nchannel_opts = length(channels);

order_est = 10;
lambda = 0.98;

verbosity = 0;

data_type = 'vrc-cp-ch2-coupling1-fixed';
data_type_params = {};
% data_type = 'vrc-cp-ch2-coupling2-rnd';
% data_type_params = {'time',358,'order',10};

%% set up benchmark params and run

%% MCMTQRDLSL1
sim_params = [];
for k=1:nchannel_opts
    nchannels = channels(k);
    sim_params(k).filter = MCMTQRDLSL1(nchannels,order_est,5,lambda);
    sim_params(k).data = data_type;
    sim_params(k).data_params = data_type_params;
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name',sim_params(1).filter.name,...
    'sim_params', sim_params,...
    'nsims', nsims,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

close all;

%% MQRDLSL1
sim_params = [];
for k=1:nchannel_opts
    nchannels = channels(k);
    sim_params(k).filter = MQRDLSL1(nchannels,order_est,lambda);
    sim_params(k).data = data_type;
    sim_params(k).data_params = data_type_params;
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name',sim_params(1).filter.name,...
    'sim_params', sim_params,...
    'nsims', nsims,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

close all;

%% MQRDLSL2
sim_params = [];
for k=1:nchannel_opts
    nchannels = channels(k);
    sim_params(k).filter = MQRDLSL2(nchannels,order_est,lambda);
    sim_params(k).data = data_type;
    sim_params(k).data_params = data_type_params;
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name',sim_params(1).filter.name,...
    'sim_params', sim_params,...
    'nsims', nsims,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

close all;

%% MLOCCD_TWL
sim_params = [];
ntime = 358;
sigma = 10^(-1);
for k=1:nchannel_opts
    nchannels = channels(k);
    % gamma = sqrt(2*sigma^2*ntime*log(norder*nchannels^2));
    gamma = sqrt(2*sigma^2*ntime*log(nchannels));
    sim_params(k).filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
    sim_params(k).data = data_type;
    sim_params(k).data_params = data_type_params;
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name',sim_params(1).filter.name,...
    'sim_params', sim_params,...
    'nsims', nsims,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

close all;


