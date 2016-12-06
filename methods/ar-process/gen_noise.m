function noise = gen_noise(nchannels, ntime, ntrials, varargin)
%GEN_NOISE generates normally distributed noise
%   GEN_NOISE(nchannels, ntime, ntrials, ...) generates normally distributed
%   noise
%
%   Input
%   -----
%   nchannels (integer)
%       number of channels
%   ntime (integer)
%       number of time samples
%   ntrials (integer)
%       number of trials
%
%   Parameters
%   ----------
%   mu (vector, default = 0)
%       mean of noise
%   sigma (matrix, default = I)
%       covariance matrix of noise
%
%   Output
%   ------
%   noise (matrix)
%       noise matrix [channels time trials]

p = inputParser();
addParameter(p,'mu',[],@isnumeric);
addParameter(p,'sigma',[],@isnumeric);
parse(p,varargin{:});

mu = p.Results.mu;
sigma = p.Results.sigma;

if isempty(mu)
    mu = zeros(nchannels,1);
end

if isempty(sigma)
    sigma = eye(nchannels);
end

noise = zeros(nchannels,ntime,ntrials);
for m=1:ntrials
    noise(:,:,m) = mvnrnd(mu,sigma,ntime)';
end

end