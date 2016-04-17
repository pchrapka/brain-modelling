%% exp14_mqrdlsl_multitrial_1channel
%
% Goal: Test the multi-trial and multichannel QRD-LSL algorithm

close all;

nchannels = 1;
ntrials = 10;
nsamples = 1000;

% a_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
coefs(1,1,:) = [1.6 -0.95];
norder = size(coefs,3);

s = VAR(nchannels,norder);
s.coefs_set(coefs);
s.coefs_stable(true)

% allocate mem for data
x = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [x(:,:,i),~,~] = s.simulate(nsamples);
end

%% Estimate the AR coefficients
% use all the data
x_all = reshape(x,nchannels,ntrials*nsamples);

order_est = 2;
[a_est, e] = lpc(x_all, order_est)

%% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Estimate the Reflection coefficients using the multi trial MQRD-LSL algorithm
order_est = 2;

lambda = 0.99;
filter = MQRDLSL2(nchannels,order_est,lambda);
trace = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
k_true = repmat(-1*k_est,1,nsamples);
trace.run(x,'verbosity',0,'mode','plot','plot_options',{'true',k_true});

% NOTE this multi trial won't work because the lattice filter assumes
% consecutive data points. multiple instances of the same data point would
% require a significantly different set up.