%% exp32_benchmark_varnocoupling

% gen data
% set filters to run and benchmark params
% run benchmark
% TODO refactor benchmark code

% exp30_tvar_vs_nchannels

% [srcdir,func_name,~] = fileparts(mfilename('fullpath'));
% outdir = fullfile(srcdir,'output');
% if ~exist(outdir,'dir')
%     mkdir(outdir);
% end

setup_parfor();

%% set up params
nsims = 20;
%channels = [2 4 6 8 10 12 14 16];
channels = [2 4];
nchannel_opts = length(channels);

order_est = 10;
lambda = 0.98;

verbosity = 0;

sim_params = [];

for k=1:nchannel_opts
    nchannels = channels(k);
    %sim_params(k).filter_name = 'MQRDLSL1';
    %sim_params(k).filter_params = {'nchannels',nchannels,'order',order_est,'lambda',lambda,'ntrials',1};
    sim_params(k).filter = MQRDLSL1(nchannels,order_est,lambda);
    %sim_params(k).data = 'var-no-coupling';
    sim_params(k).data = 'vrc-2ch-coupling';
    sim_params(k).label = '';
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name','',...
    'sim_params', sim_params,...
    'nsims', 20,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);


% sim_params(k).filter_name = 'MQRDLSL2';
% sim_params(k).filter_params = {'nchannels',nchannels,'order',order_est,'lambda',lambda,'ntrials',1};
% sim_params(k).data = 'var-no-coupling';
% sim_params(k).label = '';
% k = k+1;
% 
% sim_params(k).filter_name = 'MCMTQRDLSL1';
% sim_params(k).filter_params = {'nchannels',nchannels,'order',order_est,'lambda',lambda,'ntrials',5};
% sim_params(k).data = 'var-no-coupling';
% sim_params(k).label = '';
% k = k+1;
% 
% sim_params(k).filter_name = 'MLOCCDTWL';
% sim_params(k).filter_params = {'nchannels',nchannels,'order',order_est,'lambda',lambda,'ntrials',1};
% sim_params(k).data = 'var-no-coupling';
% sim_params(k).label = '';
% k = k+1;




