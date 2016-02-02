%% exp01_qrd_lsl
close all;

nsamples = 1000;
a_coefs = [1 -1.6 0.95];  % from Friedlander1982, case 1
[~,x] = gen_stationary_ar(a_coefs,nsamples);

%% Estimate the AR coefficients
M = 2;
[a_est, e] = lpc(x, M)

%% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Estimate the Reflection coefficients using the QRD-LSL algorithm
i=1;
lattice = [];

M = 2;
lambda = 0.99;
lattice(i).alg = QRDLSL(M,lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('QRDLSL M%d lambda=%0.2f',M,lambda);
i = i+1;

% estimate the reflection coefficients
lattice = estimate_reflection_coefs(lattice, x);

%% Compare true and estimated

figure;
plot_reflection_coefs(lattice, k_true);