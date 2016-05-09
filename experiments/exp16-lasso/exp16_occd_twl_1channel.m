%% exp16_occd_twl_1channel
%
% Goal: Test the OCCD-TWL algorithm

close all;

nchannels = 1;
ntrials = 1;
nsamples = 200;

% a_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
coefs(1,1,:) = [0.7 0 0 -0.55 0 0];
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
x_all = x;

order_est = norder;
[a_est, e] = lpc(x_all, order_est)

%% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Estimate the AR coefficients using the OCD TWL
order_est = norder;

sigma = 10^(-1);
lambda = sqrt(2*sigma^2*nsamples*log(norder));
beta = 0.99;
filter = OCCD_TWL(order_est,lambda,beta);
trace = LatticeTrace(filter,'fields',{'x'});

% run the filter
figure;
%k_est_mat(:,1,1) = k_est;
coefs_true = shiftdim(coefs,2);
a_true = repmat(coefs_true,1,1,1,nsamples);
a_true = shiftdim(a_true,3);
trace.run(x,'verbosity',2,'mode','plot',...
    'plot_options',{'ch1',1,'ch2',1,'true',a_true,'fields',{'x'}});

%% Estimate the reflection coefs using MQRDLSL1

lambda = 0.99;
filter = MQRDLSL1(nchannels,order_est,lambda);
trace = LatticeTrace(filter,'fields',{'Kf'});

k_est_mat(:,1,1) = k_est;
k_true = repmat(-1*k_est_mat,1,1,1,nsamples);
k_true = shiftdim(k_true,3);

% run the filter
figure;
trace.run(x(:,:,1),'verbosity',2,'mode','plot',...
    'plot_options',{'ch1',1,'ch2',1,'true',k_true,'fields',{'Kf'}});
