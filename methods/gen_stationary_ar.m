function [x,x_norm] = gen_stationary_ar(a, nsamples)
%GEN_STATIONARY_AR generates a stationary AR process
%   GEN_STATIONARY_AR(A, NSAMPLES) generates a stationary AR process
%
%   Input
%   -----
%   a (vector)
%       AR coefficients
%   nsamples (integer)
%       number of samples to generate
%
%   Output
%   ------
%   x (vector)
%       stationary AR process
%   x_norm
%       normalized stationary AR process, with a variance of 1


noise = randn(nsamples,1);

x = filter(1, a, noise);

% normalize x to unit variance
x_norm = x/std(x);
disp(var(x/std(x))) % should be 1

end