%% exp25_sta_vs_dyn_4channel

trial_idx = 1:5;
ntrials = length(trial_idx);

%% get data

nchannels = 4;
nsamples = 1000;
norder = 4;

s = VRCStep(nchannels,norder,ceil(nsamples/2));
% s = VAR(nchannels,norder);
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
    %s.coefs_gen(); % PROBLEM not the best model either
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

%% estimate connectivity with RC
lambda = 0.99;

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

% run the filter on data
trace{k} = LatticeTrace(filter,'fields',{'Kf'});
trace{k}.noise_warmup(noise);
trace{k}.run(sources(:,:,1),'verbosity',verbosity,'mode','none');
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
for i=1:order_est
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    %Aest(:,:,i) = AR(:,idx_start:idx_end);
    kest(i,:,:) = RC(:,idx_start:idx_end);
end
kest_time = repmat(kest,1,1,1,nsamples);
kest_time = shiftdim(kest_time,3);
trace{k}.name = 'Nuttall Strand';
trace{k}.trace.Kf = kest_time;
k = k+1;

%% estimate connectivity with mscohere

%% plot traces
mode = 'image-order';
for i=1:length(trace)
    fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
    figure('Name',fig_name,'NumberTitle','off')
    plot_rc(trace{i}.trace,'mode',mode,'clim','none','abs',true,'threshold','none');
    
    fig_name = sprintf('Trace %d: %s',i,trace{i}.name);
    figure('Name',fig_name,'NumberTitle','off')
    plot_rc(trace{i}.trace,'mode',mode,'clim',[0 1.5],'abs',true,'threshold',1.5);
end

