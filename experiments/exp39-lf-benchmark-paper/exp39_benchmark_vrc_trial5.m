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
    var_gen = VARGenerator(gen_params{:});
    if var_gen.hasprocess
        fresh = false;
    else
        var_gen.configure(gen_config_params{:});
        fresh = true;
    end
    data_var = var_gen.generate(ntrials);
    
    [nchannels,nsamples,~] = size(data_var.signal_norm);
    
    data_file = fullfile(file_path,outdir,'tuning-data.mat');
    if fresh || isfresh(data_file,var_gen.get_file())
        save_parfor(data_file, data_var.signal_norm);
    end
    
    idx_start = floor(nsamples*0.05);
    idx_end = ceil(nsamples*0.95);
    
    func_bayes = @(x) tune_lattice_filter(...
        data_file,...
        fullfile(file_path,outdir),...
        'filter','MCMTLOCCD_TWL4',...
        'filter_params',{nchannels,norder,ntrials,'lambda',lambda,'gamma',x(1)},...
        'criteria','normtime',...
        'criteria_samples',[idx_start idx_end]);
    
    n = 1;
    ub = [10]; %[gamma]
    lb = zeros(n,1);
    
    params_bayes = [];
    [x_opt,y] = bayesoptcont(func_bayes, n, params_bayes, lb, ub);
    
    error('set gamma to %g and set flag_tune to false\n',x_opt);
    
end

%% set filter parameters

gamma = 1;

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
exp_path = fullfile(file_path,[outdir '.m']);

run_lattice_benchmark(...
    'outdir',outdir,...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', nsims,...
    'warmup_noise', false,...
    'normalized',true,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);