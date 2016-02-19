%% exp06_mqrdlsl_4channelind
% 4 independent channels
close all;
clear all;

nsamples = 1000;
order = 2;
nchannels = 4;
%a_coefs = [1 0.082*ones(1,order)];  % from Lewis1990
a_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
A = zeros(order+1, nchannels, nchannels);
for ch=1:nchannels
    A(:,ch,ch) = a_coefs;
end
[~,X] = gen_stationary_ar(A,nsamples);

%% Estimate the AR coefficients
for ch=1:nchannels
    [a_est, e] = lpc(X(ch,:), order)
end

%% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_coefs,e)

%% Estimate the Reflection coefficients using the QRD-LSL algorithm
i=1;
lattice = [];

% nchannels from above
% order from above
lambda = 0.99;
lattice(i).alg = MQRDLSL1(nchannels,order,lambda);
lattice(i).scale = -1;
lattice(i).name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',nchannels,order,lambda);
i = i+1;

% estimate the reflection coefficients
lattice = estimate_reflection_coefs(lattice, X);

%% Compare true and estimated
k_true = repmat(k_est,1,nsamples);

for ch=1:nchannels
    figure;
    plot_reflection_coefs(lattice, k_true, nsamples, ch, ch);
end