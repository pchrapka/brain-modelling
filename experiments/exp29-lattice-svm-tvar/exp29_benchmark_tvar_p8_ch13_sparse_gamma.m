%% exp29_benchmark_tvar_p8_ch13_sparse_gamma

%% set options
nsims = 20;
nchannels = 13;

order_est = 8;
lambda = 0.98;

verbosity = 0;

data_type = 'vrc-cp-ch2-coupling2-rnd';
data_params = {};

% set up the data set first
params_sd_tvar_p8_ch13('mode','short');

%% set up benchmark params

ngammas = 6;
gamma = linspace(1,40,ngammas);

k=1;
config = [];
config(k).filter = 'MLOCCD_TWL';
config(k).name = 'sparsegamma';
k=k+1;
config(k).filter = 'MLOCCD_TWL2';
config(k).name = 'sparse2gamma';
k=k+1;
nconfigs = length(config);


for j=1:nconfigs
    k=1;
    sim_params = [];
    
    for i=1:ngammas
        
        filter_func = str2func(config(j).filter);
        sim_params(k).filter = filter_func(nchannels,order_est,...
            'lambda',lambda,'gamma',gamma(i));
        sim_params(k).data = data_type;
        sim_params(k).data_params = data_params;
        sim_params(k).label = sim_params(k).filter.name;
        k = k+1;
        
    end
    
    %% run
    exp_path = [mfilename('fullpath') '.m'];
    
    run_lattice_benchmark(...
        exp_path,...
        'name',config(j).name,...
        'sim_params', sim_params,...
        'nsims', 20,...
        'warmup_noise', true,...
        'warmup_data', true,...
        'normalized',true,...
        'force',false,...
        'plot_avg_mse', true,...
        'plot_avg_nmse', true);
    
end
