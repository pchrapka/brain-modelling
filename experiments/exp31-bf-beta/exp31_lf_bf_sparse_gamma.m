%% exp31_lf_bf_sparse_gamma

stimulus = 'std';
subject = 6;
deviant_percent = 10;
% patch_model = 'aal';
patch_model = 'aal-coarse-13';
patch_options = {...
    'patchmodel',patch_model,...
    'patchoptions',{}};

params_data = DataBeta(subject,deviant_percent);

pipeline = build_pipeline_beamformerpatch(...
    paramsbf_sd_beta(subject,deviant_percent,stimulus,patch_options{:}),...
    get_data_beta_pipedir()); 
pipeline.process();

%% set options
switch patch_model
    case 'aal-coarse-13'
        nchannels = 13;
    case 'aal'
        nchannels = 106;
end
ntrials = 20;

nsamples = 800; % TODO remove

order_est = 10;
lambda = 0.99;

verbosity = 0;

name = sprintf('lf-bf-ch%d-%s-%s',nchannels,params_data.data_name,stimulus);

%% set up benchmark params
gammas = linspace(1,30,10);

filters = {};
for k=1:length(gammas)    
    filters{k} = MCMTLOCCD_TWL2(nchannels,order_est,ntrials,'lambda',lambda,'gamma',gammas(k));
end

%% load data
parfor_setup();

outfile = fullfile('output',[name '.mat']);

if exist(outfile,'file')
    sources = loadfile(outfile);
else
    % load data
    data = loadfile(pipeline.steps{end}.sourceanalysis);
    % extract data
    sources = bf_get_sources(data);
    clear data;
    
    % data should be [channels time trials]
    save_tag(sources,'outfile',outfile);
end

% check max trials
% don't put in more data than required i.e. ntrials + ntrials_warmup
ntrials_max = 2*ntrials;
sourcesfile = fullfile('output',sprintf('%s-trials%d.mat',name,ntrials_max));

if ~exist(sourcesfile,'file')
    sources = sources(:,:,1:ntrials_max);
    save_tag(sources,'outfile',sourcesfile);
    clear sources
end

%% run lattice filters
script_name = [mfilename('fullpath') '.m'];

outfiles = run_lattice_filter(...
    sourcesfile,...
    'outdir',name,...
    'basedir',script_name,...
    'filters', filters,...
    'warmup',{'noise','data'},...
    'force',false,...
    'plot_pdc', false);

%% plot

% plot_pdc_dynamic_from_lf_files(outfiles);

plot_rc_dynamic_from_lf_files(outfiles,'outdir',script_name,'save', true);


