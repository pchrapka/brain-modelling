%% pdc_analysis_params_tune_mini
flag_test = true;

if flag_test
    flag_plot = false;
    
    ntrials = 5;
    nchannels = 10;
    norder = 8;
    [file_path,~,~] = fileparts(mfilename('fullpath'));
    outdir = fullfile('output','tune-mini-test');
    
    orders = [4 5];
    lambdas = [0.98 0.99];
    gammas = [0.0001 0.1 1 10];
    
    gen_params = {...
        'vrc-full-coupling-rnd',nchannels,...
        'version','exp39-sparsity0-05'};

    nsamples = 2000;
    gen_config_params = {...
        'order',norder,...
        'nsamples', nsamples,...
        'channel_sparsity', 0.4,...
        'coupling_sparsity', 0.05};
    
    tune_file = tune_file_from_generator(...
        fullfile(file_path,outdir),...
        'gen_params',gen_params,...
        'gen_config_params',gen_config_params,...
        'ntrials',ntrials);
else
    flag_plot = false;
        
    ntrials = 20;
    
    orders = 3:14;
    
    lambdas = [0.94 0.96 0.98 0.99 0.995];
    
    gammas_exp = [-10:4:-2 0 1] ;
    gammas = [10.^gammas_exp 5 20 30];
    gammas = sort(gammas);
    
    % TODO get file for tuning
end

% get data size info from tune_file
tune_data = loadfile(tune_file);
[nchannels,nsamples,~] = size(tune_data);

idx_start = floor(nsamples*0.15);
idx_end = ceil(nsamples*0.95);
criteria_samples = [idx_start idx_end];
run_options = {'warmup_noise', false,'warmup_data', false};

tune_lattice_filter_parameters(...
    tune_file,...
    fullfile(file_path,outdir),...
    'plot',flag_plot,...
    'filter','MCMTLOCCD_TWL4',...
    'ntrials',ntrials,...
    'gamma',gammas,...
    'lambda',lambdas,...
    'order',orders,...
    'run_options',run_options,...
    'criteria_samples',criteria_samples);



