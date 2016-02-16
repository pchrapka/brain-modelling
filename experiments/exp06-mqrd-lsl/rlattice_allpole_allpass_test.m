%% rlattice_allpole_allpass_test
close all;

%% Generate stationary AR process using filter
nsamples = 1000;
a_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
[x,~,noise] = gen_stationary_ar(a_coefs,nsamples);

% Estimate the AR coefficients
M = 2;
[a_est, e] = lpc(x, M)

% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Generate stationary AR process using reverse lattice
% X = randn(1,nsamples);
[~,~,k_coefs] = rlevinson(a_coefs,e)
Kf = k_coefs;
Kb = Kf;
Y = rlattice_allpole_allpass(Kf,Kb,noise);

% Estimate the AR coefficients
M = 2;
[a_est, e] = lpc(Y, M)

% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Generate stationary AR process using latticear from MATLAB
Hd = dfilt.latticear(k_coefs);
y_matlab = Hd.filter(noise);

%% Plot both
figure;
subplot(3,1,1);
plot(x);
subplot(3,1,2);
plot(Y);
subplot(3,1,3);
plot(y_matlab);