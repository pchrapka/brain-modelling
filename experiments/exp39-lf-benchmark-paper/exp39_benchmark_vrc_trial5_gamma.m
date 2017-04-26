%% exp39_benchmark_vrc_trial5_gamma

params_vrc_stationary

%% set parameters

outdir = 'vrc-stationary-trial5-nowarmup-gamma';
[file_path,~,~] = fileparts(mfilename('fullpath'));

nsims = 1;
ntrials = 5;
lambda = 0.99;

%% set up benchmark params

k=1;
sim_params = [];

% gamma_exp = [-14:2:0 1];
gamma_exp = [-2:1:2];
gamma = 10.^gamma_exp;

for k=1:length(gamma);
    
    sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma(k));
    sim_params(k).gen_params = gen_params;
    sim_params(k).gen_config_params = gen_config_params;
    sim_params(k).label = sprintf('gamma %g',gamma(k));
    k = k+1;
end

sim_params(k).filter = BurgVector(nchannels,norder,'nsamples',nsamples);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = sim_params(k).filter.name;
k = k+1;

%% run
[~,data_name,~] = fileparts(var_gen.get_file());
exp_path = fullfile(file_path,[outdir '.m']);

run_lattice_benchmark(...
    'outdir',fullfile(outdir,data_name),...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', nsims,...
    'warmup_noise', false,...
    'warmup_data', false,...
    'normalized',true,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);