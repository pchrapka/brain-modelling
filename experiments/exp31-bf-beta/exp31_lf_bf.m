%% exp31_lf_bf

stimulus = 'std';
subject = 6;
deviant_percent = 10;
% patches_type = 'aal';
patches_type = 'aal-coarse-13';

[~,data_name,~] = get_data_andrew(subject,deviant_percent);

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,'patches',patches_type)); 
pipeline.process();

%% set options
switch patches_type
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

name = sprintf('lf-bf-ch%d-%s-%s',nchannels,data_name,stimulus);

%% set up benchmark params

k=1;
filters = {};

% filters{k} = MCMTQRDLSL1(nchannels,order_est,ntrials,lambda);
% k = k+1;

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

% filters{k} = BurgVectorWindow(nchannels,order_est,'nwindow',30);
% k = k+1;
% 
% filters{k} = BurgVectorWindow(nchannels,order_est,'nwindow',60);
% k = k+1;
% 
% filters{k} = BurgVectorWindow(nchannels,order_est,'nwindow',60,'ntrials',ntrials);
% k = k+1;
% 
% filters{k} = BurgVector(nchannels,order_est,'nsamples',nsamples/4);
% k = k+1;
% 
% filters{k} = BurgVector(nchannels,order_est,'nsamples',nsamples/2);
% k = k+1;
% 
% filters{k} = BurgVector(nchannels,order_est,'nsamples',nsamples);
% k = k+1;

%% load data
setup_parfor();

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
    % NOTE don't put in more data than required i.e. ntrials + ntrials_warmup
    save_tag(sources,'outfile',outfile);
end

% check max trials
% don't put in more data than required i.e. ntrials + ntrials_warmup
ntrials_max = 2*ntrials;
outfile = fullfile('output',sprintf('%s-trials%d.mat',name,ntrials_max));

if ~exist(outfile,'file')
    sources = sources(:,:,1:ntrials_max);
    save_tag(sources,'outfile',outfile);
    clear sources
end

%% run lattice filters
script_name = [mfilename('fullpath') '.m'];

outfiles = run_lattice_filter(...
    script_name,...
    outfile,...
    'name',name,...
    'filters', filters,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',false,...
    'plot_pdc', false);

%% plot

plot_pdc_dynamic_from_lf_files(outfiles);

% for i=1:length(outfiles)
%     data = loadfile(outfiles{i});
%     h = figure;
%     [~,name,~] = fileparts(outfiles{i});
%     set(h,'NumberTitle','off','MenuBar','none', 'Name', name );
%     set(h, 'Position', [50, 50, 1100, 900]);
%     plot_rc_dynamic(data.estimate.Kf);
%     save_fig_exp(script_name,'tag', [name '-rc-dynamic']);
% end


