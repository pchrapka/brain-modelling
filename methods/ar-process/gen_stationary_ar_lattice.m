function [X,X_norm,noise] = gen_stationary_ar_lattice(Kf, Kb, nsamples)
%GEN_STATIONARY_AR_LATTICE generates a stationary AR process with a lattice
%filter
%   [X,X_norm,noise] = GEN_STATIONARY_AR_LATTICE(Kf, Kb, nsamples)
%   generates a stationary AR process using a lattice filter
%
%   Input
%   -----
%   Kf (matrix)
%       forward reflection coefficients, [order channels channels]
%   Kb (matrix)
%       backward reflection coefficients, [order channels channels]
%   nsamples (integer)
%       number of samples to generate
%
%   Output
%   ------
%   X (matrix)
%       stationary AR process, [channels nsamples]
%   X_norm (matrix)
%       normalized stationary AR process, with a variance of 1,
%       [channels nsamples]
%   noise (matrix)
%       noise

nchannels = size(Kf,2);

noise = randn(nchannels, nsamples);
X = rlattice_allpole_allpass(Kf,Kb,noise);

% NOTE Normalizing the variance is actually incredibly important to get
% sensible results

% normalize the variance
X_norm = normalizev(X);

end