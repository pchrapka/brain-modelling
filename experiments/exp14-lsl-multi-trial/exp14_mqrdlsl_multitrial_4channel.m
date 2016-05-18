%% exp14_mqrdlsl_multitrial_4channel
%
% Goal: Test the multi-trial and multichannel QRD-LSL algorithm

close all;

nchannels = 4;
ntrials = 10;
nsamples = 200;
norder = 3;

s = VAR(nchannels,norder);
s.coefs_gen();
s.coefs_stable(true)

% allocate mem for data
x = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [~,x(:,:,i),~] = s.simulate(nsamples);
end

%% Estimate the AR and reflection coefficients using stationary method
% % use all the data
% x_all = reshape(x,nchannels,ntrials*nsamples);

% Simulate long signal to get a good estimate of the true reflection
% coefficients, use lots of samples to get a good estimate of the truth
nsamples_long = 100000;
[~,Y,~] = s.simulate(nsamples_long);

% Estimate reflection coefs using mvar
method = 13;
[AR,RC,PE] = tsa.mvar(Y', norder, method);
Aest = zeros(nchannels,nchannels,norder);
Kest_stationary = zeros(norder,nchannels,nchannels);
for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    Aest(:,:,i) = AR(:,idx_start:idx_end);
    Kest_stationary(i,:,:) = RC(:,idx_start:idx_end);
    
    fprintf('order %d\n\n',i);
    fprintf('VAR coefficients\n');
    fprintf('Actual\n');
    disp(s.A(:,:,i));
    fprintf('Estimated\n');
    disp(Aest(:,:,i));
    fprintf('\n');
    
    fprintf('Reflection coefficients\n');
    fprintf('Estimated\n');
    disp(squeeze(Kest_stationary(i,:,:)));
    fprintf('\n');
    
end
%display(RC);

k_true = repmat(Kest_stationary,1,1,1,nsamples);
k_true = shiftdim(k_true,3);

%% Estimate the Reflection coefficients 
plot_options = {'ch1',1,'ch2',1,'true',k_true};

%% MCMTQRDLSL1 with 10 trials
order_est = 3;
verbosity = 1;

lambda = 0.99;
filter = MCMTQRDLSL1(ntrials,nchannels,order_est,lambda);
trace = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace.run(x,'verbosity',verbosity,'mode','plot',...
    'plot_options',plot_options);

%% MCMTQRDLSL1 with 2 trials

lambda = 0.99;
filter = MCMTQRDLSL1(2,nchannels,order_est,lambda);
trace = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace.run(x(:,:,1:2),'verbosity',verbosity,'mode','plot',...
    'plot_options',plot_options);

%% Compare to MQRDLSLS1

filter = MQRDLSL1(nchannels,order_est,lambda);
% filter = MQRDLSL2(nchannels,order_est,lambda);
trace = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
    'plot_options',plot_options);