%% exp38_warmup_flipstate


%% set options
% nsims = 20;
nsims = 1;
nsims_benchmark = nsims;
nchannels = 4;

order_est = 10;
lambda = 0.99;

verbosity = 0;

% data_type = 'vrc-coupling0-fixed';
% nsamples = 2000;
% data_params = {'nsamples', nsamples};

data_type = 'vrc-cp-ch2-coupling1-fixed';
data_params = {};

%% set up filter

ntrials = 5;
sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

%% run benchmarks
exp_path = [mfilename('fullpath') '.m'];

k=1;
sim_params = [];

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

run_lattice_benchmark(...
    'outdir',fullfile('output','warmupnoisedata'),...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', nsims_benchmark,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'warmup_data_same',false,...
    'warmup_flipdata',false,... % doesn't matter if it's not the same
    'warmup_flipstate',false,... % doesn't matter if the data is not flipped
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

k=1;
sim_params = [];

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

run_lattice_benchmark(...
    'outdir',fullfile('output','warmupnoisedatasame'),...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', nsims_benchmark,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'warmup_data_same',true,...
    'warmup_flipdata',false,...
    'warmup_flipstate',false,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

k=1;
sim_params = [];

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

run_lattice_benchmark(...
    'outdir',fullfile('output','warmupnoiseflipdatasame'),...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', nsims_benchmark,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'warmup_data_same',true,...
    'warmup_flipdata',true,...
    'warmup_flipstate',false,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

k=1;
sim_params = [];

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

run_lattice_benchmark(...
    'outdir',fullfile('output','warmupnoiseflipdatasameflipstate'),...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', nsims_benchmark,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'warmup_data_same',true,...
    'warmup_flipdata',true,...
    'warmup_flipstate',true,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

