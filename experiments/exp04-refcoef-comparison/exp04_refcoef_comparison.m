%% exp04_refcoef_comparison
close all;

nsamples = 1000;
a_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
[~,x] = gen_stationary_ar(a_coefs,nsamples);

figure;
plot(x);

%% Estimate the AR coefficients
M = 2;
[a_est, e] = lpc(x, M)

%% Estimate the Reflection coefficients from the AR coefficients
[~,~,k_est] = rlevinson(a_est,e)

%% Estimate the Reflection coefficients using a windowed Burg's algorithm
i = 1;

M = 2;
nwindow = 10;
lambda = 0;
lattice(i).alg = BurgWindow(M, nwindow, lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('BurgWindow M%d W%d lambda=%0.2f',M,nwindow,lambda);
i = i+1;

M = 2;
nwindow = 50;
lambda = 0;
lattice(i).alg = BurgWindow(M, nwindow, lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('BurgWindow M%d W%d lambda=%0.2f',M,nwindow,lambda);
i = i+1;

M = 2;
beta = 0.1;
lambda = 0.99;
lattice(i).alg = GAL(M, beta, lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('GAL M%d beta=%0.2f lambda=%0.2f',M,beta,lambda);
i = i+1;

M = 2;
lambda = 0.99;
lattice(i).alg = QRDLSL(M,lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('QRDLSL M%d lambda=%0.2f',M,lambda);
i = i+1;

% estimate the reflection coefficients
lattice = estimate_reflection_coefs(lattice, x);

%% Compare true and estimated
k_true = repmat(k_est,1,nsamples);
k_true = [k_true; zeros(M-ncoefs,nsamples)];

figure;
plot_reflection_coefs(lattice, k_true);