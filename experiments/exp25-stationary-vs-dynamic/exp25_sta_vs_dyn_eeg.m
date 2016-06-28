%% exp25_sta_vs_dyn_eeg

trial_idx = 1:5;
ntrials = length(trial_idx);

simulated = false;

%% get data

if simulated
    % PROBLEMS difficult to simulate a stable sparse process
    
    nchannels = 13;
    nsamples = 358;
    norder = 5;
    
    %s = VRC(nchannels,norder);
    s = VAR(nchannels,norder);
    % PROBLEM can't reliably simulate a stable sparse process
    stable = false;
    
    ncoefs = nchannels^2*norder;
    sparsity = 0.1;
    ncoefs_sparse = ceil(ncoefs*sparsity);
    while ~stable
        %s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse);
        s.coefs_gen(); % PROBLEM not the best model either
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
    
else
    
    % load bf filtered data
    params = params_sd_22_consec();
    data = ftb.util.loadvar(params.conds(1).file);
    
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

order_est = 10;
verbosity = 0;
% lambda = 0.99;
lambda = 0.95;

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
kest_time = repmat(kest,1,1,1,nsamples);
kest_time = shiftdim(kest_time,3);
trace{k}.name = 'Nuttall Strand';
trace{k}.trace.Kf = kest_time;
k = k+1;

aest_time = repmat(aest,1,1,1,nsamples);
aest_time = shiftdim(aest_time,3);
trace{k}.name = 'Nuttall Strand AR';
trace{k}.trace.Kf = aest_time;
k = k+1;

%% estimate connectivity with mscohere
nfreq = 129;
cxy = zeros(nchannels, nchannels, nfreq);
for i=1:nchannels
    for j=1:nchannels
        cxy(i,j,:) = mscohere(sources(i,:,1), sources(j,:,1),[]);
    end
end
cxy = shiftdim(cxy,-1);
cxy_time = shiftdim(cxy,3);
trace{k}.name = 'Coherence';
trace{k}.trace.Kf = cxy_time;
k = k+1;

%% plot traces
mode = 'image-order';
for i=1:length(trace)
    
    switch mode
        case 'image-order'
            %fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
            %figure('Name',fig_name,'NumberTitle','off')
            %plot_rc(trace{i}.trace,'mode',mode,'clim','none','abs',true,'threshold','none');
            
            fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
            figure('Name',fig_name,'NumberTitle','off')
            plot_rc(trace{i}.trace,'mode',mode,'clim',[0 1.5],'abs',true,'threshold',1.5);
    end
end

%% movie
do_movie = true;

if do_movie
    %i = 1;
    %i = 4; % mt5
    %i = 5; % sparse
    %i = 7; % mqrdlsl noise warmup
    %i = 8; % mt5 noise warmup
    %i = 9; % nuttall strand
    i = 10; % nuttall strand AR
    %i = 11; % coherence
    fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
    figure('Name',fig_name,'NumberTitle','off')
    plot_rc(trace{i}.trace,'mode','movie-order','clim',[0 1.5],'abs',true,'threshold',1.5);
end

