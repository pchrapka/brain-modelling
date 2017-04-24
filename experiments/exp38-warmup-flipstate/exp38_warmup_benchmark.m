%% exp38_warmup_benchmark

%% set options
% nsims = 20;
nsims = 1;
nsims_benchmark = nsims;
nchannels = 4;

order_est = 10;
lambda = 0.99;

verbosity = 0;

gen_params = {'vrc-coupling0-fixed',nchannels};
nsamples = 2000;
gen_config_params = {'nsamples', nsamples};

% gen_params = {'vrc-cp-ch2-coupling1-fixed',nchannels};
% gen_config_params = {};

%% set up filters and params

ntrials = 5;
sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

k=1;
sim_params = [];

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data_sections = {'data','noise','noise'};
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = [sim_params(k).data_sections{:}];
k = k+1;

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data_sections = {'noise','data','noise'};
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = [sim_params(k).data_sections{:}];
k = k+1;

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data_sections = {'noise','data','data'};
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = [sim_params(k).data_sections{:}];
k = k+1;

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data_sections = {'noise','flipdata','data'};
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = [sim_params(k).data_sections{:}];
k = k+1;

%% run benchmarks
exp_path = [mfilename('fullpath') '.m'];
run_lattice_warmup_benchmark(...
    'outdir',fullfile('output','warmupbenchmark'),...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'normalized',true,...
    'nsims', nsims_benchmark,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);