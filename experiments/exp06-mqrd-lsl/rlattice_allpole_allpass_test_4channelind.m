%% rlattice_allpole_allpass_test_4channelind
close all;

%% Generate stationary AR process using filter
nsamples = 1000;
order = 2;
nchannels = 4;
a_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
A = zeros(order+1, nchannels, nchannels);
for ch=1:nchannels
    A(:,ch,ch) = a_coefs;
end
[X,~,noise] = gen_stationary_ar(A,nsamples);

% Estimate the AR coefficients
M = 2;
[a_est, e] = lpc(X(1,:), M)

% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_coefs,e)

%% Generate stationary AR process using reverse lattice
% X = randn(1,nsamples);
[~,~,k_coefs] = rlevinson(a_coefs,e)

Kf = zeros(order, nchannels, nchannels);
for ch=1:nchannels
    Kf(:,ch,ch) = k_coefs;
end
Kb = Kf;
Y = rlattice_allpole_allpass(Kf,Kb,noise);

% Estimate the AR coefficients
M = 2;
[a_est, e] = lpc(Y(1,:), M)

% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Plot both
for i=1:nchannels
    figure;
    subplot(2,1,1);
    plot(X(i,:));
    title(sprintf('channel %d',i));
    subplot(2,1,2);
    plot(Y(i,:));
end