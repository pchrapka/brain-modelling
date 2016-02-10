%% exp03_gal
close all;

nsamples = 1000;
a_coefs = [1 -1.6 0.95];  % from Friedlander1982, case 1
[~,x] = gen_stationary_ar(a_coefs,nsamples);

%% Estimate the AR coefficients
M = 2;
[a_est, e] = lpc(x, M)

%% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Estimate the Reflection coefficients using the Gradient Adaptive Lattice algorithm
i=1;
lattice = [];

M = 2;
lattice(i).alg = GAL(M);
lattice(i).scale = 1;
lattice(i).name = sprintf('GAL M%d beta=%0.2f lambda=%0.2f',M,lattice(i).alg.beta,lattice(i).alg.lambda);
i = i+1;

% estimate the reflection coefficients
lattice = estimate_reflection_coefs(lattice, x);

%% Compare true and estimated
k_true = repmat(k_est,1,nsamples);

figure;
plot_reflection_coefs(lattice, k_true);