%% exp05_qrdlsl
close all;

% create the data
exp05_data

%% Estimate the Reflection coefficients using a windowed Burg's algorithm
i = 1;
lattice = [];

M = 2;
lambda = 0.97;
lattice(i).alg = QRDLSL(M,lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('QRDLSL M%d lambda=%0.2f',M,lambda);
i = i+1;
% The trade off between variance and speed of convergence here doesn't seem
% worth it

M = 2;
lambda = 0.98;
lattice(i).alg = QRDLSL(M,lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('QRDLSL M%d lambda=%0.2f',M,lambda);
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

figure;
plot_reflection_coefs(lattice, k_true);