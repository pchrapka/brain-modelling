%% exp25_sta_vs_dyn_eeg

close all;

trial_idx = 1:5;
ntrials = length(trial_idx);

data_source = 'simulated';
% data_source = 'beamformed';
% data_source = 'eeg';

%% get data

switch data_source
    case 'simulated'
        
        nchannels = 13;
        nsamples = 358;
        norder = 11;
        order_est = 11;
        
        s = VRC(nchannels,norder);
        %s = VAR(nchannels,norder);
        stable = false;
        
        ncoefs = nchannels^2*norder;
        sparsity = 0.1;
        ncoefs_sparse = ceil(ncoefs*sparsity);
        while ~stable
            s.coefs_gen_sparse(...
                'structure','fullchannels',...
                'mode','exact',...
                'ncoefs',ncoefs_sparse,...
                'ncouplings',ceil(ncoefs_sparse/4),...
                'stable',true,'verbose',1);
            stable = s.coefs_stable(true);
            
            if stable
                sources = zeros(nchannels,nsamples,ntrials);
                [~,sources(:,:,1),~] = s.simulate(nsamples);
                
                h = figure;
                nrows = nchannels;
                ncols = 1;
                for i=1:nchannels
                    subaxis(nrows, ncols, i,...
                        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
                    
                    plot(squeeze(sources(i,:,1)));
                    set(gca,'xticklabel',[]);
                    xlim([1 nsamples]);
                    
                    hold off;
                end
                
                prompt = 'Accept VRC? (y)';
                response = input(prompt,'s');
                switch response
                    case 'y'
                        close(h);
                    otherwise
                        stable = false;
                end
            end
            
        end
        
        % allocate mem for data
        sources = zeros(nchannels,nsamples,ntrials);
        for i=1:ntrials
            [~,sources(:,:,i),~] = s.simulate(nsamples);
        end
    
    case 'beamformed'
        
        order_est = 11;
        
        % load bf filtered data
        params = params_sd_22_consec();
        data = loadfile(params.conds(1).file);
        
        % get source data
        sources = bf_get_sources(data(1));
        [nchannels, nsamples] = size(sources);
        
        sources = zeros(nchannels, nsamples, ntrials);
        for i=1:ntrials
            m = trial_idx(i);
            sources(:,:,i) = bf_get_sources(data(m));
            
            % normalize variance of each channel to unit variance
            sources(:,:,i) = sources(:,:,i)./repmat(std(sources(:,:,i),0,2),1,nsamples);
        end
        
    case 'eeg'
        order_est = 10;
        
        % get preprocessed data file
        analysis = build_analysis_beamform_patch_consec();
        eegobj = analysis{1}.steps{end}.get_dep('ftb.EEG');
        
        % load data
        data = loadfile(eegobj.preprocessed);
        
        % TODO should i limit the number of channels??
        idx_channel = 1:16;
        
        [~, nsamples] = size(data.trial{1});
        nchannels = length(idx_channel);
        sources = zeros(nchannels, nsamples, ntrials);
        
        for i=1:ntrials
            m = trial_idx(i);
            temp = data.trial{m};
            sources(:,:,i) = temp(idx_channel,:);
            
            % normalize variance of each channel to unit variance
            sources(:,:,i) = sources(:,:,i)./repmat(std(sources(:,:,i),0,2),1,nsamples);
        end
       
    otherwise
        error('unknown data source');
end

figure;
nrows = nchannels;
ncols = 1;

for i=1:nchannels
    subaxis(nrows, ncols, i,...
        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
    
    plot(squeeze(sources(i,:,1)));
    set(gca,'xticklabel',[]);
    xlim([1 nsamples]);
    
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

%% true RC coefs
if isequal(data_source,'simulated')
    ktrue = zeros(order_est, nchannels, nchannels);
    for i=1:s.P
        ktrue(i,:,:) = s.Kf(:,:,i);
    end
    data_sta{m}.coef = ktrue;
    data_sta{m}.name = 'True';
    m = m+1;
end

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
filter = MCMTQRDLSL1(mt,nchannels,order_est,lambda);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
trace{k}.run(sources(:,:,1:mt),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

mt = 5;
filter = MCMTQRDLSL1(mt,nchannels,order_est,lambda);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
trace{k}.run(sources(:,:,1:mt),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

% sparse
sigma = 10^(-1);
% gamma = sqrt(2*sigma^2*nsamples*log(norder*nchannels^2));
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));
filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
trace{k}.name = trace{k}.filter.name;
k = k+1;

%% estimate connectivity with RC with noise warmup

filter = MQRDLSL2(nchannels,order_est,lambda);

mu = zeros(nchannels,1);
sigma = eye(nchannels);
% noise = zeros(nchannels,nsamples,1);
noise = mvnrnd(mu,sigma,nsamples)';

% run the filter on noise
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.run(noise,'verbosity',verbosity,'mode','none');
trace{k}.name = ['noise only ' trace{k}.filter.name];
k = k+1;

% run the filter on data
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
trace{k}.name = ['noise warmup ' trace{k}.filter.name];
k = k+1;

mt = 5;
filter = MCMTQRDLSL1(mt,nchannels,order_est,lambda);

mu = zeros(nchannels,1);
sigma = eye(nchannels);
noise = zeros(nchannels,nsamples,mt);
for j=1:mt
    noise(:,:,j) = mvnrnd(mu,sigma,nsamples)';
end

% run the filter on noise
trace_noise = LatticeTrace(filter,'fields',{'Kf'});
trace_noise.run(noise,'verbosity',verbosity,'mode','none');

% run the filter on data
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
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
% kest_time = repmat(kest,1,1,1,nsamples);
% kest_time = shiftdim(kest_time,3);
% trace{k}.name = 'Nuttall Strand';
% trace{k}.trace.Kf = kest_time;
% k = k+1;
% 
% aest_time = repmat(aest,1,1,1,nsamples);
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
%         fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
%         figure('Name',fig_name,'NumberTitle','off')
%         plot_rc(trace{i}.trace,'mode','image-order','clim','none','abs',true,'threshold','none');
        
        fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_rc(trace{i}.trace,'mode','image-order','clim',[0 1.5],'abs',true,'threshold',1.5);
        
%         fig_name = sprintf('Trace %d: %s (Max)',i,trace{i}.name);
%         figure('Name',fig_name,'NumberTitle','off')
%         plot_rc(trace{i}.trace,'mode','image-max','clim','none','abs',true,'threshold',1.5);
    end
end

%% plot stationary data
do_stationary = true;
if do_stationary
    for i=1:length(data_sta)
        fig_name = sprintf('Trace %d: %s',i,data_sta{i}.name);
        figure('Name',fig_name,'NumberTitle','off','Position', [100, 100, 1300, 400])
        plot_rc_stationary(data_sta{i},'mode','image-order','clim',[0 1.5],'abs',true,'threshold',1.5);
        
        fig_name = sprintf('Trace %d: %s (No Thresh)',i,data_sta{i}.name);
        figure('Name',fig_name,'NumberTitle','off','Position', [100, 100, 1300, 400])
        plot_rc_stationary(data_sta{i},'mode','image-order','clim','none','abs',true,'threshold','none');
        
        fig_name = sprintf('Trace %d: %s (Max)',i,data_sta{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_rc_stationary(data_sta{i},'mode','image-max','clim','none','abs',true,'threshold','none');
    end
end

%% plot coh
do_coh = false;
if do_coh
    for i=1:length(data_coh)
        fig_name = sprintf('Trace %d: %s',i,data_coh{i}.name);
        figure('Name',fig_name,'NumberTitle','off')
        plot_coherence(data_coh{i});
    end
end

%% movie
do_movie = true;

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

