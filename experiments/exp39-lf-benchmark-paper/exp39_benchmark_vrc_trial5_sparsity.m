%% exp39_benchmark_vrc_trial5_sparsity

%% set options
% nsims = 20;
nchannels = 10;
% nchannels = 4;

norder = 8;
verbosity = 0;

nsims = 1;
ntrials = 5;
lambda = 0.99;

%% set data params
params_sp = [];
k = 1;

params_sp(k).sparsity = 0.01;
params_sp(k).gamma = 3.897;
params_sp(k).label = '0-01';
k = k+1;

params_sp(k).sparsity = 0.05;
params_sp(k).gamma = 4.55;
params_sp(k).label = '0-05';
k = k+1;

params_sp(k).sparsity = 0.1;
params_sp(k).gamma = 3.85;
params_sp(k).label = '0-1';
k = k+1;

params_sp(k).sparsity = 0.2;
params_sp(k).gamma = NaN;
params_sp(k).label = '0-2';
k = k+1;

var_params = [];
for i=1:length(params_sp)
    var_params(i).gen_params = {...
        'vrc-full-coupling-rnd',nchannels,...
        'version',sprintf('exp39-sparsity%s',params_sp(i).label)};
    var_params(i).gamma = params_sp(i).gamma;
    if isnan(params_sp(i).gamma)
        var_params(i).flag_tune = true;
    else
        var_params(i).flag_tune = false;
    end
    
    % each channel is a sparse VRC process
    % there is a certain level of coupling sparsity
    % there is at least one coefficient in the max order specified
    nsamples = 2000;
    var_params(i).gen_config_params = {...
        'order',norder,...
        'nsamples', nsamples,...
        'channel_sparsity', 0.4,...
        'coupling_sparsity', params_sp(i).sparsity};
end

%% set parameters

outdir = 'vrc-stationary-trial5-nowarmup-sparsity';
[file_path,~,~] = fileparts(mfilename('fullpath'));

%% tune parameters
opt = zeros(length(var_params),1);
for i=1:length(var_params)
    if var_params(i).flag_tune
        tune_file = tune_file_from_generator(...
            fullfile(file_path,outdir),...
            'gen_params',var_params(i).gen_params,...
            'gen_config_params',var_params(i).gen_config_params,...
            'ntrials',ntrials);
        
        filter_params = [];
        filter_params.nchannels = nchannels;
        filter_params.ntrials = ntrials;
        filter_params.lambda = lambda;
        filter_params.norder = norder;
        
        %idx_start = floor(nsamples*0.05);
        idx_start = floor(nsamples*0.15);
        idx_end = ceil(nsamples*0.95);
        
        gammas_exp = [-15 -10 -5 -1 0 1];
        gammas = [10.^gammas_exp 5 20 30];
        gammas = sort(gammas);
        opt(i) = tune_lattice_filter_gamma(...
            tune_file,...
            fullfile(file_path,outdir),...
            'plot_fit',true,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'gamma',gammas,...
            'run_options',{'warmup_noise',false, 'warmup_data', false},...
            'criteria_samples',[idx_start idx_end]);
        fprintf('set gamma to %g for process %d\n',opt(i),i);
    end
end
    
for i=1:length(var_params)
    
    %% set up benchmark params
    k=1;
    sim_params = [];
    
    sim_params(k).filter = MCMTQRDLSL1(nchannels,norder,ntrials,lambda);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sim_params(k).filter.name;
    k = k+1;
    
    sim_params(k).filter = MQRDLSL3(nchannels,norder,lambda);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sim_params(k).filter.name;
    k = k+1;
    
    % sigma = sqrt(0.1);
    % gamma = sqrt(2*sigma^2*nsamples*log(nchannels));
    
    sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,...
        'lambda',lambda,'gamma',var_params(i).gamma);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sim_params(k).filter.name;
    k = k+1;
    
    %% run
    [~,data_name,~] = fileparts(var_gen(i).get_file());
    exp_path = fullfile(file_path,'output',[outdir '.m']);
    
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
        'plot_avg_nmse', false);
end