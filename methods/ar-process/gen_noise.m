function noise = gen_noise(nchannels, ntime, ntrials, varargin)

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