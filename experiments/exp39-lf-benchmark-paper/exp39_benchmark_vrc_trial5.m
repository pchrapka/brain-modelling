%% exp39_benchmark_vrc_trial5

params_vrc_stationary

%% set parameters

outdir = 'vrc-stationary-trial5-nowarmup';
[file_path,~,~] = fileparts(mfilename('fullpath'));

nsims = 5;
ntrials = 5;
lambda = 0.99;

%% tune parameters
flag_tune = false;
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
    gamma = 4.55;
else
    gamma = 8.88;
end

%% set up benchmark params

k=1;
sim_params = [];

sim_params(k).filter = MQRDLSL3(nchannels,norder,lambda);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = strrep(sim_params(k).filter.name,'MQRDLSL3','MQRDLSL');
k = k+1;

sim_params(k).filter = MCMTQRDLSL1(nchannels,norder,ntrials,lambda);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = strrep(sim_params(k).filter.name,'MCMTQRDLSL1','MCMTQRDLSL');
k = k+1;

% sigma = sqrt(0.1);
% gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = strrep(sim_params(k).filter.name,'MCMTLOCCD_TWL4','MCMTLOCCD-TWL');
k = k+1;

% NOTE gamma was not explicitly tuned for this one
sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',0.90,'gamma',gamma);
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = strrep(sim_params(k).filter.name,'MCMTLOCCD_TWL4','MCMTLOCCD-TWL');
k = k+1;

%% run
[~,data_name,~] = fileparts(var_gen.get_file());
exp_path = fullfile(file_path,'output',[outdir '.m']);

out_files = run_lattice_benchmark(...
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

ylim([10^(-2) 10^(-0.9)]);
ylabel('Reflection Coefficient MSE');
xlim([1 1000]);
xlabel('Sample');
set(gca,'fontsize',16)

save_fig2('path',fullfile(file_path,'output',outdir,data_name),...
    'tag','benchmark-paper',...
    'formats',{'eps'},...
    'nodate',true,...
    'save_flag', true);