%% exp29_benchmark_tvar_p8_ch13_mt_trials

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

ntrials_tests = 6;
ntrials = linspace(5,48,ntrials_tests);
ntrials = ceil(ntrials);

sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

k=1;
config = [];
config(k).filter = 'MCMTQRDLSL1';
config(k).params = {lambda};
config(k).name = 'mtdensetrials';
k=k+1;
config(k).filter = 'MCMTLOCCD_TWL2';
config(k).params = {'lambda',lambda,'gamma',gamma};
config(k).name = 'mtsparse2trials';
k=k+1;
config(k).filter = 'MCMTLOCCD_TWL3';
config(k).params = {'lambda',lambda,'gamma',gamma};
config(k).name = 'mtsparse3trials';
k=k+1;
nconfigs = length(config);


for j=1:nconfigs
    k=1;
    sim_params = [];
    
    for i=1:ntrials_tests
        
        filter_func = str2func(config(j).filter);
        sim_params(k).filter = filter_func(nchannels,order_est,ntrials(i),...
            config(j).params{:});
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
