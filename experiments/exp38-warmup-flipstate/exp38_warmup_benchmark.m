%% exp38_warmup_benchmark

%% set options
% nsims = 20;
nsims = 5;
nsims_benchmark = nsims;
nchannels = 4;

norder = 10;
lambda = 0.99;

verbosity = 0;

% gen_params = {'vrc-coupling0-fixed',nchannels};
% nsamples = 2000;
% gen_config_params = {'nsamples', nsamples};

% gen_params = {'vrc-cp-ch2-coupling1-fixed',nchannels};
% gen_config_params = {};

% keep only one changepoint
gen_params = {'vrc-cp-ch2-coupling1-fixed',nchannels,...
    'version','exp38-cp1'};
gen_config_params = {'changepoints', [122 1000]};

outdir = fullfile('output','warmupbenchmark');
file_path = mfilename('fullpath');

ntrials = 5;

%% set up filters and params

sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

k=1;
sim_params = [];

% sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
% sim_params(k).data_sections = {'data','noise','noise'};
% sim_params(k).gen_params = gen_params;
% sim_params(k).gen_config_params = gen_config_params;
% sim_params(k).label = [sim_params(k).data_sections{:}];
% k = k+1;
% 
% sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
% sim_params(k).data_sections = {'noise','data','noise'};
% sim_params(k).gen_params = gen_params;
% sim_params(k).gen_config_params = gen_config_params;
% sim_params(k).label = [sim_params(k).data_sections{:}];
% k = k+1;
% 
% sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
% sim_params(k).data_sections = {'noise','data','data'};
% sim_params(k).gen_params = gen_params;
% sim_params(k).gen_config_params = gen_config_params;
% sim_params(k).label = [sim_params(k).data_sections{:}];
% k = k+1;
% 
% sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
% sim_params(k).data_sections = {'noise','flipdata','data'};
% sim_params(k).gen_params = gen_params;
% sim_params(k).gen_config_params = gen_config_params;
% sim_params(k).label = [sim_params(k).data_sections{:}];
% k = k+1;

% sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
% sim_params(k).data_sections = {'flipdata','data','noise'};
% sim_params(k).gen_params = gen_params;
% sim_params(k).gen_config_params = gen_config_params;
% sim_params(k).label = [sim_params(k).data_sections{:}];
% k = k+1;

% 2 sections
% NOTE: noise doesn't seem to help with the sparse method, it does help
% with the MQRSLSL methods though
sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data_sections = {'noise','data'};
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = [sim_params(k).data_sections{:}];
k = k+1;

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data_sections = {'data','data'};
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = [sim_params(k).data_sections{:}];
k = k+1;

sim_params(k).filter = MCMTLOCCD_TWL4(nchannels,norder,ntrials,'lambda',lambda,'gamma',gamma);
sim_params(k).data_sections = {'flipdata','data'};
sim_params(k).gen_params = gen_params;
sim_params(k).gen_config_params = gen_config_params;
sim_params(k).label = [sim_params(k).data_sections{:}];
k = k+1;


%% run benchmarks
exp_name = [file_path '.m'];
run_lattice_warmup_benchmark(...
    'outdir',outdir,...
    'basedir',exp_name,...
    'sim_params', sim_params,...
    'normalized',true,...
    'nsims', nsims_benchmark,...
    'force',false,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', false);