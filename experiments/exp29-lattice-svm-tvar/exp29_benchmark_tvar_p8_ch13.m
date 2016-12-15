%% exp29_benchmark_tvar_p8_ch13

%% set options
nsims = 20;
nchannels = 13;

order_est = 8;
lambda = 0.98;

verbosity = 0;

data_type = 'vrc-cp-ch2-coupling2-rnd';
data_params = {};

% set up the data set first
params_sd_tvar_p8_ch13('mode','short');

%% set up benchmark params

k=1;
sim_params = [];

ntrials = 5;
sim_params(k).filter = MCMTQRDLSL1(nchannels,order_est,ntrials,lambda);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

sim_params(k).filter = MQRDLSL3(nchannels,order_est,lambda);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));
sim_params(k).filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

sim_params(k).filter = MCMTLOCCD_TWL2(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

sim_params(k).filter = MCMTLOCCD_TWL3(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data = data_type;
sim_params(k).data_params = data_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

%% run
exp_path = [mfilename('fullpath') '.m'];

run_lattice_benchmark(...
    exp_path,...
    'name','warmupnoisedatanormalized',...
    'sim_params', sim_params,...
    'nsims', 20,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'normalized',true,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);
