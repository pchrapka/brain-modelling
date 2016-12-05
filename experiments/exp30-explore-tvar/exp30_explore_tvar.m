%% exp30_explore_tvar

[srcdir,func_name,~] = fileparts(mfilename('fullpath'));

trial_idx = 1:5;
ntrials = length(trial_idx);

%% generate data

norder = 8;
nchannels = 3;
ntime = 358;

conds = [];
conds(1).label = 'std';
conds(2).label = 'odd';
ncond = length(conds);

outdir = fullfile(srcdir,'output');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% ncoefs = norder;
% sparsity = 0.1;
% ncoefs_sparse = ceil(ncoefs*sparsity);
ncoefs_sparse = 2;

ncouplings = 2;

% Rationale: for each condition use the same VAR models for the constant
% and pulse processes, change the coupling and changepoints to account for
% the change in condition

% set up 2 1-channel VAR model with random coefficients
vrc1 = VRC(1, norder);
vrc1.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,...
    'stable',true,'verbose',1);

vrc2 = VRC(1, norder);
vrc2.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,...
    'stable',true,'verbose',1);

source_channels = randsample(1:nchannels,2);

% set const to vrc 1
vrc_const = zeros(nchannels, nchannels, norder);
vrc_const(source_channels(1),source_channels(1),:) = vrc1.Kf;

% set pulse to vrc 2
vrc_pulse_source = zeros(nchannels, nchannels, norder);
vrc_pulse_source(source_channels(2),source_channels(2),:) = vrc2.Kf;

% set different changepoints for the conditions
changepoints = {};
changepoints{1} = [20 100] + (ntime - 256);
changepoints{2} = [50 120] + (ntime - 256);

for i=1:ncond
    % set up params
    conds(i).file = fullfile(outdir,...
        sprintf('%s-%s.mat',strrep(func_name,'_','-'),conds(i).label));
    
    % check if the data file exists
    if ~exist(conds(i).file,'file')
        stable = false;
        while ~stable

            % modify coupling for each condition
            vrc_coupling = zeros(nchannels, nchannels, norder);
            coupling_count = 0;
            while coupling_count < ncouplings
                
                coupled_channels = randsample(source_channels,2);
                coupled_order = randsample(1:norder,1);
                
                % check if we've already chosen this one
                if vrc_coupling(coupled_channels(1),coupled_channels(2),coupled_order) == 0
                    % generate a new coefficient
                    vrc_coupling(coupled_channels(1),coupled_channels(2),coupled_order) = unifrnd(-1, 1);
                    % increment counter
                    coupling_count = coupling_count + 1;
                end
            end
            
            % add const and coupling to pulse
            vrc_pulse = vrc_const + vrc_coupling + vrc_pulse_source;
            
            vrc_constpulse = VRCConstAndPulse(nchannels, norder, changepoints{i});
            
            vrc_constpulse.coefs_set(vrc_const, vrc_const, 'const');
            vrc_constpulse.coefs_set(vrc_pulse, vrc_pulse, 'pulse');
            
            % check stability
            verbosity = false;
            stable = vrc_constpulse.coefs_stable(verbosity);
            if ~stable
                fprintf('not stable\n');
            end
        end
            
        % generate data
        data = [];
        data.signal = zeros(nchannels,ntime,ntrials);
        data.signal_norm = zeros(nchannels,ntime,ntrials);
        for j=1:ntrials
            % simulate process
            [signal,signal_norm,~] = vrc_constpulse.simulate(ntime);
            
            data.signal(:,:,j) = signal;
            data.signal_norm(:,:,j) = signal_norm;
        end
        
        % save true coefficients
        data.true = vrc_constpulse.get_coefs_vs_time(ntime,'Kf');
        
        % save data
        save(conds(i).file,'data');
    else
        fprintf('data exists: %s\n',conds(i).file);
    end

end

%% select data

sources = [];
ktrue = [];

data_source = 'odd';
data_type = 'normalized'; 
% data_type = 'original'; 

finding_data_source = true;
i = 1;
while finding_data_source
    if i > length(conds)
        error('data source not found %s\n',data_source);
    end
    
    if isequal(conds(i).label,data_source)
        data = loadfile(conds(i).file);
        switch data_type
            case 'normalized'
                sources = data.signal_norm;
                ktrue = data.true;
            case 'original'
                sources = data.signal;
                ktrue = data.true;
        end
        finding_data_source = false;
    end
    
    i = i+1;
end

figure;
nrows = nchannels;
ncols = 1;

for i=1:nchannels
    subaxis(nrows, ncols, i,...
        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
    
    plot(squeeze(sources(i,:,1)));
    set(gca,'xticklabel',[]);
    xlim([1 ntime]);
    
    hold off;
end

%% estimate connectivity
k = 1;
trace = {};
m = 1;
data_sta = {};
n = 1;
data_coh = {};

verbosity = 0;
% lambda = 0.99;
lambda = 0.98;
% lambda = 0.95;
% lambda = 0.9;

order_est = 10;

sigma = 10^(-1);
% gamma = sqrt(2*sigma^2*ntime*log(norder*nchannels^2));
gamma = sqrt(2*sigma^2*ntime*log(nchannels));

%% true RC coefs

% data_sta{m}.coef = s.Kf;
% data_sta{m}.name = 'True';
% m = m+1;

trace{k}.trace.Kf = s.Kf;
trace{k}.name = 'True';
k = k+1;

%% estimate connectivity with RC

filter = MQRDLSL1(nchannels,order_est,lambda);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

filter = MQRDLSL2(nchannels,order_est,lambda);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

% multi trial
mt = 2;
filter = MCMTQRDLSL1(nchannels,order_est,mt,lambda);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
trace{k}.run(sources(:,:,1:mt),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

mt = 5;
filter = MCMTQRDLSL1(nchannels,order_est,mt,lambda);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
trace{k}.run(sources(:,:,1:mt),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

% sparse
filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

%% estimate connectivity with RC with noise warmup

filter = MQRDLSL2(nchannels,order_est,lambda);

mu = zeros(nchannels,1);
sigma = eye(nchannels);
% noise = zeros(nchannels,ntime,1);
noise = mvnrnd(mu,sigma,ntime)';

% run the filter on data
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.warmup(noise);
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
trace{k}.name = ['noise warmup ' trace{k}.filter.name];
k = k+1;

% sparse
filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);

% run the filter on data
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.warmup(noise);
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
trace{k}.name = ['noise warmup ' trace{k}.filter.name];
k = k+1;

mt = 5;
filter = MCMTQRDLSL1(nchannels,order_est,mt,lambda);

mu = zeros(nchannels,1);
sigma = eye(nchannels);
noise = zeros(nchannels,ntime,mt);
for j=1:mt
    noise(:,:,j) = mvnrnd(mu,sigma,ntime)';
end

% run the filter on data
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.warmup(noise);
trace{k}.run(sources(:,:,1:mt),'verbosity',verbosity,'mode','none');
trace{k}.name = ['noise warmup ' trace{k}.filter.name];
k = k+1;

%% estimate connectivity with Nuttall Strand

% prep data
x = sources(:,:,1)';

% estimate
method = 13;
[AR,RC,PE] = tsa.mvar(x, order_est, method);

% transform estimates into common data struct
kest = zeros(order_est, nchannels, nchannels);
aest = zeros(order_est, nchannels, nchannels);
for i=1:order_est
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    aest(i,:,:) = AR(:,idx_start:idx_end);
    kest(i,:,:) = RC(:,idx_start:idx_end);
end
% kest_time = repmat(kest,1,1,1,ntime);
% kest_time = shiftdim(kest_time,3);
% trace{k}.name = 'Nuttall Strand';
% trace{k}.trace.Kf = kest_time;
% k = k+1;
% 
% aest_time = repmat(aest,1,1,1,ntime);
% aest_time = shiftdim(aest_time,3);
% trace{k}.name = 'Nuttall Strand AR';
% trace{k}.trace.Kf = aest_time;
% k = k+1;

% data_sta{m}.name = 'TVAR NS';
% data_sta{m}.coef = kest;
% m = m+1;

% data_sta{m}.name = 'TVAR NS AR';
% data_sta{m}.coef = aest;
% m = m+1;

%% estimate connectivity with Burgv

x = permute(sources(:,:,1),[1 3 2]);
Lmax = 20;
[pcsel,R0] = ARselv(x,Lmax);
fprintf('Estimated model order: %d\n', size(pcsel,3));

[pc, R0] = burgv(x,order_est);

data_sta{m}.coef = shiftdim(pc(:,:,2:end),2);
data_sta{m}.name = 'PC Burgv';
m = m+1;

% convert parcor to rc
[rcf,rcb,~,~] = pc2rcv(pc,R0);

data_sta{m}.coef = shiftdim(rcf(:,:,2:end),2);
data_sta{m}.name = 'RCF Burgv';
m = m+1;

% data_sta{m}.coef = shiftdim(rcb(:,:,2:end),2);
% data_sta{m}.name = 'RCB Burgv';
% m = m+1;

% convert parcor to ar
[arest,~] = pc2arset(pc,R0);
data_sta{m}.coef = shiftdim(arest(:,:,2:end),2);
data_sta{m}.name = 'AR Burgv';
m = m+1;

%% estimate connectivity with mscohere
nfreq = 129;
cxy = zeros(nchannels, nchannels, nfreq);
for i=1:nchannels
    for j=1:nchannels
        cxy(i,j,:) = mscohere(sources(i,:,1), sources(j,:,1),[]);
    end
end
% cxy_time = shiftdim(shiftdim(cxy,-1),3);
% trace{k}.name = 'mscohere';
% trace{k}.trace.Kf = cxy_time;
% k = k+1;

data_coh{n}.name = 'mscohere';
data_coh{n}.coef = cxy;
data_coh{n}.f = linspace(0,0.5,nfreq);
n = n+1;

%% plot traces
do_traces = true;
if do_traces
    for i=1:length(trace)
        
        % image-order
        fig_name = sprintf('Trace %s: (No Thresh) %s',data_source,trace{i}.name);
        figure('Name',fig_name,'NumberTitle','off','Position', [100, 100, 1300, 400])
        plot_rc(trace{i}.trace,'mode','image-order','clim','none','abs',true,'threshold','none');
        
%         fig_name = sprintf('Trace %s: (Thresh 1.5) %s',data_source,trace{i}.name);
%         figure('Name',fig_name,'NumberTitle','off','Position', [100, 100, 1300, 400])
%         plot_rc(trace{i}.trace,'mode','image-order','clim',[0 1.5],'abs',true,'threshold',1.5);
        
%         fig_name = sprintf('Trace %s: (Max) %s',data_source,trace{i}.name);
%         figure('Name',fig_name,'NumberTitle','off','Position', [100, 100, 1300, 400])
%         plot_rc(trace{i}.trace,'mode','image-max','clim','none','abs',true,'threshold',1.5);
    end
end

%% plot stationary data
do_stationary = false;
if do_stationary
    for i=1:length(data_sta)
        fig_name = sprintf('Trace %s: (Thresh 1.5) %s',data_source,data_sta{i}.name);
        figure('Name',fig_name,'NumberTitle','off','Position', [100, 100, 1300, 400])
        plot_rc_stationary(data_sta{i},'mode','image-order','clim',[0 1.5],'abs',true,'threshold',1.5);
        
        fig_name = sprintf('Trace %s: (No Thresh) %s',data_source,data_sta{i}.name);
        figure('Name',fig_name,'NumberTitle','off','Position', [100, 100, 1300, 400])
        plot_rc_stationary(data_sta{i},'mode','image-order','clim','none','abs',true,'threshold','none');
        
        fig_name = sprintf('Trace %s: (Max) %s',data_source,data_sta{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_rc_stationary(data_sta{i},'mode','image-max','clim','none','abs',true,'threshold','none');
    end
end

%% plot coh
do_coh = false;
if do_coh
    for i=1:length(data_coh)
        fig_name = sprintf('Trace %s: %s',data_source,data_coh{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_coherence(data_coh{i});
    end
end

%% movie
do_movie = false;

if do_movie
    %i = 1;
    %i = 4; % mt5
    i = 5; % sparse
    %i = 7; % mqrdlsl noise warmup
    %i = 8; % mt5 noise warmup
    %i = 9; % nuttall strand
    %i = 10; % nuttall strand AR
    %i = 11; % coherence
    
    mode = 'movie-order';
    position = [100, 100, 1300, 400];
%     mode = 'movie-max';
%     position = [100, 100, 400, 400];
    
%     fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
%     figure('Name',fig_name,'NumberTitle','off')
%     plot_rc(trace{i}.trace,'mode',mode,'clim',[0 1.5],'abs',true,'threshold',1.5);
    
    fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
    figure('Name',fig_name,'NumberTitle','off','Position', position)
    plot_rc(trace{i}.trace,'mode',mode,'clim',[0 1.5],'abs',true,'threshold','none');
end
