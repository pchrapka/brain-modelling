%% exp39_benchmark_vrc_trial5_sparsity

%% set options
% nsims = 20;
nchannels = 10;
% nchannels = 4;

norder = 8;
verbosity = 0;

nsims = 5;
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
params_sp(k).gamma = 3.57;
params_sp(k).label = '0-2';
k = k+1;

params_sp(k).sparsity = 0.5;
params_sp(k).gamma = 2.18;
params_sp(k).label = '0-5';
k = k+1;

params_sp(k).sparsity = 0.8;
params_sp(k).gamma = 2.43;
params_sp(k).label = '0-8';
k = k+1;

var_params = [];
for i=1:length(params_sp)
    var_params(i).gen_params = {...
        'vrc-full-coupling-rnd',nchannels,...
        'version',sprintf('exp39-sparsity%s',params_sp(i).label)};
    var_params(i).gamma = params_sp(i).gamma;
    var_params(i).sparsity = params_sp(i).sparsity;
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
            fullfile(file_path,'output',outdir),...
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
            fullfile(file_path,'output',outdir),...
            'plot_gamma_fit',true,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'gamma',gammas,...
            'run_options',{'warmup',{}},...
            'criteria_samples',[idx_start idx_end]);
        fprintf('set gamma to %g for process %d\n',opt(i),i);
    end
end

k=1;
sim_params = [];
for i=1:length(var_params)
    
    %% set up benchmark params
    
    sim_params(k).filter = MQRDLSL3(nchannels,norder,lambda);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sprintf('%0.2f %s',var_params(i).sparsity,sim_params(k).filter.name);
    sim_params(k).label2 = strrep(sim_params(k).filter.name,'MQRDLSL3','MQRDLSL');
    sim_params(k).sparsity = var_params(i).sparsity;
    k = k+1;
    
    sim_params(k).filter = MCMTQRDLSL1(nchannels,norder,ntrials,lambda);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sprintf('%0.2f %s',var_params(i).sparsity,sim_params(k).filter.name);
    sim_params(k).label2 = strrep(sim_params(k).filter.name,'MCMTQRDLSL1','MCMTQRDLSL');
    sim_params(k).sparsity = var_params(i).sparsity;
    k = k+1;
    
    % sigma = sqrt(0.1);
    % gamma = sqrt(2*sigma^2*nsamples*log(nchannels));
    
    sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,...
        'lambda',lambda,'gamma',var_params(i).gamma);
    sim_params(k).gen_params = var_params(i).gen_params;
    sim_params(k).gen_config_params = var_params(i).gen_config_params;
    sim_params(k).label = sprintf('%0.2f %s',var_params(i).sparsity,sim_params(k).filter.name);
    sim_params(k).label2 = strrep(sim_params(k).filter.name,'MCMTLOCCD_TWL4','MCMTLOCCD-TWL');
    sim_params(k).sparsity = var_params(i).sparsity;
    k = k+1;
    
end

%% run
exp_path = fullfile(file_path,'output',[outdir '.m']);

out_files = run_lattice_benchmark(...
    'outdir',outdir,...
    'basedir',exp_path,...
    'sim_params', sim_params,...
    'nsims', nsims,...
    'warmup',{},...
    'normalized',true,...
    'force',false,...
    'plot_avg_mse', false,...
    'plot_avg_nmse', false);

%% plot MSE vs sparsity
nsparsity = length(params_sp);
[nparams,nsims] = size(out_files);
nfilters = nparams/nsparsity;

% reorganize data
data_series = [];
for i=1:nparams
    idx_filter = mod(i,nfilters);
    if idx_filter == 0
        idx_filter = 3;
    end
    idx_sparsity = floor((i-1)/nfilters)+1;
    
    estimate = cell(nsims,1);
    truth = cell(nsims,1);
    for j=1:nsims
        data_bench = loadfile(out_files{i,j});
        estimate{j} = data_bench.estimate;
        truth{j} = data_bench.truth;
    end
    data_series(idx_filter).estimate{idx_sparsity} = estimate;
    data_series(idx_filter).truth{idx_sparsity} = truth;
end

h = figure('Position',[1 1 800 500]);
idx_start = ceil(nsamples/2);
idx_end = nsamples;

labels = cell(nfilters,1);
for i=1:nfilters
    labels{i} = sim_params(i).label2;
end

plot_mse_vs_sparsity(...
    data_series,...
    [params_sp.sparsity],...
    'labels',labels,...
    'samples',[idx_start idx_end],...
    'normalized',false,...
    'mode','loglog');
xlabel('Non-Zero Coefficients (%)');
set(gca,'fontsize',14)

% save
save_fig2('path',fullfile(file_path,'output',outdir),...
    'tag','sparsity-paper',...
    'formats',{'eps'},...
    'nodate',true,...
    'save_flag', true);
