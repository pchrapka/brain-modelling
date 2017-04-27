%% exp39_benchmark_vrc_trial5

params_vrc_stationary

%% set parameters

outdir = 'vrc-stationary-trial5-nowarmup';
[file_path,~,~] = fileparts(mfilename('fullpath'));

nsims = 1;
ntrials = 5;
lambda = 0.99;

%% tune parameters
flag_tune = true;
if flag_tune
    tune_file = tune_file_from_generator(...
        fullfile(file_path,outdir),...
        'gen_params',gen_params,...
        'gen_config_params',gen_config_params,...
        'ntrials',ntrials);
    
    filter_params = [];
    filter_params.nchannels = nchannels;
    filter_params.ntrials = ntrials;
    filter_params.lambda = lambda;
    filter_params.norder = norder;
    
    %idx_start = floor(nsamples*0.05);
    idx_start = floor(nsamples*0.15);
    idx_end = ceil(nsamples*0.95);
    
    gammas_exp = -14:2:1;
    gammas = [10.^gammas_exp 5 20 30];
    gammas = sort(gammas);
    opt = tune_lattice_filter_gamma(...
        tune_file,...
        fullfile(file_path,outdir),...
        'plot_fit',true,...
        'filter','MCMTLOCCD_TWL4',...
        'filter_params',filter_params,...
        'gamma',gammas,...
        'run_options',{'warmup_noise', false,'warmup_data', false},...
        'criteria_samples',[idx_start idx_end]);
    
    error('set gamma to %g and set flag_tune to false\n',opt);
    
end

%% set filter parameters

if nchannels == 10
    gamma = 1e-4;
    % bayesopt goes down to 1.6e-14 but when you plot it seems to level off
    % at 1e-4
else
    gamma = 1e-2;
    % bayesopt goes down to 1.29-14 but when you plot it seems to level off
    % at ?
end

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

% sigma = sqrt(0.1);
% gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
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