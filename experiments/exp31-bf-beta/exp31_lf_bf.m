%% exp31_lf_bf

stimulus = 'std';
subject = 6;
deviant_percent = 10;

[~,data_name,~] = get_data_andrew(subject,deviant_percent);

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(subject,deviant_percent,stimulus)); 
pipeline.process();

%% set options
nchannels = 13;
ntrials = 20;
ntrials_warmup = 5;

order_est = 10;
lambda = 0.99;

verbosity = 0;

name = sprintf('lf-bf-ch%d-%s-%s',nchannels,data_name,stimulus);

%% set up benchmark params

k=1;
filters = {};

filters{k} = MCMTQRDLSL1(nchannels,order_est,ntrials,lambda);
k = k+1;

filters{k} = MQRDLSL1(nchannels,order_est,lambda);
k = k+1;

filters{k} = MQRDLSL2(nchannels,order_est,lambda);
k = k+1;

filters{k} = MQRDLSL3(nchannels,order_est,lambda);
k = k+1;

sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));
filters{k} = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
k = k+1;

filters{k} = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma*2);
k = k+1;

filters{k} = MLOCCD_TWL2(nchannels,order_est,'lambda',lambda,'gamma',gamma);
k = k+1;

filters{k} = MCMTLOCCD_TWL2(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gamma);
k = k+1;

filters{k} = BurgVectorWindow(nchannels,order_est,'nwindow',30);
k = k+1;

filters{k} = BurgVectorWindow(nchannels,order_est,'nwindow',60);
k = k+1;

filters{k} = BurgVectorWindow(nchannels,order_est,'nwindow',60,'ntrials',5);
k = k+1;

filters{k} = BurgVector(nchannels,order_est,'nsamples',nsamples/4);
k = k+1;

filters{k} = BurgVector(nchannels,order_est,'nsamples',nsamples/2);
k = k+1;

filters{k} = BurgVector(nchannels,order_est,'nsamples',nsamples);
k = k+1;

%% load data

% TODO get data name
data = loadfile(pipeline.steps{end}.sourceanalysis);
error('fix bf_get_sources to deal with multiple trials');
sources = bf_get_sources(data);
clear data;
ntrials_max = ntrials + ntrials_warmup;
sources = sources(:,:,1:ntrials_max);
% data should be [channels time trials]
% NOTE don't put in more data than required i.e. ntrials + ntrials_warmup

%% run
script_name = [mfilename('fullpath') '.m'];

run_lattice_filter(...
    script_name,...
    sources,...
    'name',name,...
    'filters', filters,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'warmup_data_ntrials',ntrials_warmup,...
    'force',false,...
    'plot_pdc', true);


