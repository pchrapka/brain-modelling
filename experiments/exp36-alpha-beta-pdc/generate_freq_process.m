function result = generate_freq_process(varargin)

p = inputParser();
addParameter(p,'nchannels',4,@(x) isnumeric(x) && x >= 2);
addParameter(p,'ntrials',1,@isnumeric);
addParameter(p,'nsamples',500,@isnumeric);
addParameter(p,'norder',4,@isnumeric);
addParameter(p,'nchannels_signal',[],@isnumeric);
addParameter(p,'ncouplings',4,@isnumeric);
addParameter(p,'freq',[8 10],@(x) length(x) == 2);
addParameter(p,'fs',512,@isnumeric);
addParameter(p,'nsamples_warmup',500,@isnumeric);
addParameter(p,'normalization','all',@(x) any(validatestring(x,{'all','channel-wise'})));
parse(p,varargin{:});

debug = false;

nsamples_total = p.Results.nsamples + p.Results.nsamples_warmup;

% randomly select number of channels with freq signal
if isempty(p.Results.nchannels_signal)
    nchannels_freq = randi([2 p.Results.nchannels],1);
else
    nchannels_freq = p.Results.nchannels_signal;
end
% randomly select indices
idx = randsample(p.Results.nchannels,nchannels_freq);

% create filter 
forder = 4;
fwn = p.Results.freq/(p.Results.fs/2);
[b,a] = butter(forder,fwn,'bandpass');

if debug
    freqz(b,a,1024,p.Results.fs);
end

% create output
result = p.Results;
result.freq_channels = idx;
result.filter.a = a;
result.filter.b = b;
result.filter.order = forder;
result.filter.type = 'butter';
result.filter.wn = fwn;

stable = false;
while ~stable
    
    % create coupling
    A = zeros(p.Results.nchannels,p.Results.nchannels,p.Results.norder);
    for i=1:p.Results.ncouplings
        coupled_channels = randsample(p.Results.nchannels,2);
        coupled_order = randsample(p.Results.norder,1);
        A(coupled_channels(1),coupled_channels(2),coupled_order) = unifrnd(-1,1);
    end
    
    data = zeros(p.Results.nchannels, nsamples_total);
    
    % generate independent signals
    mu = 0;
    sigma = 0.01;
    signal = normrnd(mu,sigma,p.Results.nchannels,nsamples_total);
    %         signal = zeros(p.Results.nchannels,nsamples_total);
    for j=1:p.Results.nchannels
        select = ~isempty(find(idx == j,1));
        if select
            % phase = randinterval(0,pi/2,{1});
            mu = 0;
            sigma = 1;
            noise = normrnd(mu,sigma,[1,nsamples_total]);
            
            % TODO add option to normalize
            signal(j,:) = signal(j,:) + filter(b,a,noise);
        end
    end
    
    % add coupling
    for s=p.Results.norder+1:nsamples_total
        % mix signal
        mixed = signal(:,s);
        for k=1:p.Results.norder
            mixed = mixed + squeeze(A(:,:,k))*signal(:,s-k);
        end
        
        % check stability
        if norm(mixed) > 10
            fprintf('unstable - retrying\n');
            stable = false;
            continue;
        end
        
        % save
        data(:,s) = mixed;
    end
    
    % if we get here, it should be stable
    stable = true;
end

% normalize
switch p.Results.normalization
    case 'channel-wise'
        data_norm = normalizev(data);
    case 'all'
        data_norm = normalize(data);
end

% remove warm up samples
data(:,1:p.Results.nsamples_warmup,:) = [];
data_norm(:,1:p.Results.nsamples_warmup,:) = [];

% split into trials
nsamples_per_trial = floor(p.Results.nsamples/p.Results.ntrials);
idx_beg = 1;
idx_end = idx_beg + nsamples_per_trial - 1;

trials = zeros(p.Results.nchannels,nsamples_per_trial,p.Results.ntrials);
trials_norm = trials;
for i=1:p.Results.ntrials
    trials(:,:,i) = data(:,idx_beg:idx_end);
    trials_norm(:,:,i) = data_norm(:,idx_beg:idx_end);
    
    idx_beg = idx_end + 1;
    idx_end = idx_beg + nsamples_per_trial - 1;
end

result.data = data;
result.data_norm = data_norm;
result.trials = trials;
result.trials_norm = trials_norm;
result.A = A;


end