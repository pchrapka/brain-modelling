%% exp39_benchmark_vrc_trial5

params_vrc_stationary

ntrials = 5;
lambda = 0.99;

%% set up benchmark params

k=1;
sim_params = [];

sim_params(k).filter = MCMTQRDLSL1(nchannels,norder,ntrials,lambda);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

sim_params(k).filter = MQRDLSL3(nchannels,norder,lambda);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

sigma = sqrt(0.1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

%% run
outdir = 'vrc-stationary-trial5-nowarmup';
[file_path,~,~] = fileparts(mfilename('fullpath'));
exp_path = fullfile(file_path,[outdir '.m']);

run_lattice_benchmark(...
    'outdir',outdir,...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', 20,...
    'warmup_noise', false,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);