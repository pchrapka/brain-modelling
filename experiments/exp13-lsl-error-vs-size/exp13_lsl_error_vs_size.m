%% exp13_lsl_error_vs_size
%   Goal:
%   Test error of MQRDLSL algorithm as a function of number of parameters

order = 2;
nchannels = 4;

%% generate VAR
s = VAR(nchannels, order);
s.coefs_gen();

% simulate data
nsamples = 1000;
[X,X_norm,noise] = s.simulate(nsamples);

%% Estimate coefs using lattice filter

% lattice = [];

% nchannels from above
% order from above
lambda = 0.99;
verbose = 1;
% % lattice(i).alg = MQRDLSL1(nchannels,order,lambda);
% lattice.alg = MQRDLSL2(nchannels,order,lambda);
% lattice.scale = 1;
% lattice.name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',nchannels,order,lambda);
% 
% % estimate the reflection coefficients
% lattice = estimate_reflection_coefs(lattice, X, verbose);

filter = MQRDLSL2(nchannels,order,lambda);
trace = LatticeTrace(filter,'fields',{'Kf','ferror'});

% run the filter
trace.run(X,'verbosity',0);

%% Calculate the relative error
% Section 3.3 in Schlogl2000

