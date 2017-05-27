%% pdc_analysis_params_tune_gamma_mini
flag_test = false;

tune_gamma_method = 'fminbnd';
% tune_mode = 'existing';
tune_mode = 'continue';
    
% tune_gamma_method = 'bayesopt';

prepend_data = 'none';

if flag_test
    flag_plot = false;
    
    ntrials = 5;
    nchannels = 10;
    norder = 8;
    [file_path,~,~] = fileparts(mfilename('fullpath'));
    outdir = fullfile(file_path,'output','tune-mini-test');
    
    order = 5;
    lambda = 0.99;
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
        outdir,...
        'gen_params',gen_params,...
        'gen_config_params',gen_config_params,...
        'ntrials',ntrials);
else
    flag_plot = false;
        
    ntrials = 20;
    
%     orders = 3:14;
    
%     lambdas = [0.94 0.96 0.98 0.99];% 0.995];
    % NOTE: lambda = 0.995 makes things very uninteresting
    
    flag_plot = true;
    order = 11;
    lambda = 0.99;
    
    %gammas_exp = [-10:4:-2 0 1] ;
    %gammas = [10.^gammas_exp 5 20 30];
    %gammas = sort(gammas);
    gammas = [10^(-6) 10^(-3)];
    
    outdir = ['/media/phil/p.eanut/'...
        'projects/brain-modelling/analysis/pdc-analysis/'...
        'output/std-s03-10/aal-coarse-19-outer-nocer-plus2'...
        ];
    sources_data_file = fullfile(outdir,...
        'lf-sources-ch12-trials100-samplesall-normeachchannel-envyes-prependflipdata.mat');
    sources_filter_file = fullfile(outdir,...
        'lf-sources-ch12-trials100-samplesall-normeachchannel-envyes-prependflipdata-for-filter.mat');
    
    tune_file = strrep(sources_filter_file,'.mat','-tuning.mat');
    copyfile(sources_filter_file, tune_file);
    
    sources_data = loadfile(sources_data_file);
    prepend_data = sources_data.prepend_data;
end

% get data size info from tune_file
tune_data = loadfile(tune_file);
[nchannels,nsamples,~] = size(tune_data);

idx_start = floor(nsamples*0.05);
idx_end = ceil(nsamples*0.95);

switch prepend_data
    case 'flipdata'
        nsamples_half = nsamples/2;
        idx_start = floor(nsamples_half*0.05) + nsamples_half;
        idx_end = ceil(nsamples_half*0.95) + nsamples_half;
end
criteria_samples = [idx_start idx_end];

% set default options to warmup
run_options = {'warmup',{'noise','data'},'verbosity',1};

switch prepend_data
    case 'flipdata'
        % no warmup necessary if lattice_filter_prep_data prepends data
        run_options = {'warmup',{},'verbosity',1};
end

[~,tunename,~] = fileparts(tune_file);
tune_outdir = tunename;

trials_dir = sprintf('trials%d',ntrials);
order_dir = sprintf('order%d',order);
lambda_dir = sprintf('lambda%g',lambda);

filter_params = [];
filter_params.nchannels = nchannels;
filter_params.ntrials = ntrials;
filter_params.norder = order;
filter_params.lambda = lambda;

switch tune_gamma_method
    case 'fminbnd'
        tune_lattice_filter_gamma(...
            tune_file,...
            fullfile(outdir,tune_outdir,trials_dir,order_dir,lambda_dir),...
            'plot_gamma',flag_plot,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'run_options',run_options,...
            'mode',tune_mode,...
            'upper_bound',max(gammas),...
            'lower_bound',min(gammas),...
            'criteria_samples',criteria_samples);
    case 'bayesopt'
        tune_lattice_filter_gamma_bayesopt(...
            tune_file,...
            fullfile(outdir,tune_outdir,trials_dir,order_dir,lambda_dir),...
            'plot_gamma_fit',flag_plot,...
            'filter','MCMTLOCCD_TWL4',...
            'filter_params',filter_params,...
            'run_options',run_options,...
            'gamma',gammas,...
            'criteria_samples',criteria_samples);
    otherwise
        error('unknown method %s',tune_gamma_method);
end



