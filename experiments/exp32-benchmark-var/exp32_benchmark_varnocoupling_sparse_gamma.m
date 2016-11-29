%% exp32_benchmark_varnocoupling_sparse_gamma


%% set options
nsims = 20;
nchannels = 4;

order_est = 10;
lambda = 0.99;

verbosity = 0;

data_type = 'vrc-coupling0-fixed';
nsamples = 2000;
data_params = {'nsamples', nsamples};

gamma = 1:7;
filters = {'MLOCCD_TWL','MLOCCD_TWL2'};

%% set up benchmark params

for j=1:length(filters)
    k=1;
    sim_params = [];
    
    filter_func = str2func(filters{j});
    
    for i=1:length(gamma)
        sim_params(k).filter = filter_func(nchannels,order_est,'lambda',lambda,'gamma',gamma(i));
        sim_params(k).data = data_type;
        sim_params(k).data_params = data_params;
        sim_params(k).label = sim_params(k).filter.name;
        k = k+1;
        
    end
    
    
    %% run
    run_lattice_benchmark(...
        mfilename('fullpath'),...
        'name','',...
        'sim_params', sim_params,...
        'nsims', 20,...
        'noise_warmup', true,...
        'force',false,...
        'plot_avg_mse', true,...
        'plot_avg_nmse', true);
    
end



