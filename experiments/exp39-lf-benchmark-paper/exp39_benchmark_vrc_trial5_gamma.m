%% exp39_benchmark_vrc_trial5_gamma

params_vrc_stationary

%% set parameters

outdir = fullfile('output','vrc-stationary-trial5-nowarmup-gamma');
[file_path,~,~] = fileparts(mfilename('fullpath'));

nsims = 1;
ntrials = 5;
lambda = 0.99;

%% set up benchmark params

k=1;
sim_params = [];

% gamma_exp = [-14:2:0 1];
gamma_exp = [-2:1:2];
gamma = [10.^gamma_exp 8.88 30 50 78.3];
gamma = sort(gamma);

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

%% run benchmark
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

%% run lattice filters

tune_file = tune_file_from_generator(...
        fullfile(file_path,outdir),...
        'gen_params',gen_params,...
        'gen_config_params',gen_config_params,...
        'ntrials',ntrials);

lf_files = run_lattice_filter(...
    tune_file,...
    'outdir',fullfile(outdir,data_name),...
    'basedir',exp_path,...
    'filters',{sim_params(1:end-1).filter},...
    'warmup_noise',false,...
    'warmup_data',false,...
    'plot_pdc',false,...
    'tracefields',{'Kf','Kb','ferror','berrord','Rf'},...
    'normalization','allchannels');


%% plot criteria
view_lf = ViewLatticeFilter(lf_files,...
    'labels',{sim_params(1:end-1).label});

% criteria = 'minorigin_normerror_norm1coefs_time';
% criteria = 'norm1coefs_time';
criteria = 'normerrortime';
% criteria = 'minorigin_deterror_norm1coefs_time';
% criteria = 'ewlogdet';
view_lf.compute({criteria});

%% plot criteria
view_lf.plot_criteria_vs_order_vs_time(...
    'criteria',criteria,...
    'orders',norder,...
    'file_list',1:length(lf_files));

%% plot residual norm vs coef norm
idx_start = floor(nsamples*0.15);
idx_end = ceil(nsamples*0.95);
    
view_lf.plot_criteria_vs_criteria(...
    'criteria1','normerrortime',...
    'criteria2','norm1coefs_time',...
    'orders',norder,...
    'file_list',1:length(lf_files),...
    'criteria_samples',[idx_start idx_end]);