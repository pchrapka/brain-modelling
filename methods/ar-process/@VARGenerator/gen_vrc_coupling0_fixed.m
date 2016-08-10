function data = gen_vrc_coupling0_fixed(obj,varargin)
%
%   Parameters
%   ----------
%   nsamples (integer)
%       number of samples to generate

p = inputParser();
addParameter(p,'nsamples',100,@isnumeric);
parse(p,varargin{:});

ntrials = obj.nsims;
nchannels = obj.nchannels;
norder = 10;

% set up fixed processes
processes = cell(2,1);

kf = zeros(1,1,norder);
kf(1,1,1) = -0.4789;
kf(1,1,6) = -0.9642;
processes{1} = kf;

kf = zeros(1,1,norder);
kf(1,1,4) = -0.6054;
kf(1,1,10) = -0.9131;
processes{2} = kf;

% setup full process
vrc = VRC(nchannels, norder);
vrc_coefs = zeros(nchannels, nchannels, norder);
for i=1:nchannels
    % choose a process randomly
    idx = randsample(length(processes),1);
    % set coefficients
    vrc_coefs(i,i,:) = processes{idx};
end
vrc.coefs_set(vrc_coefs,vrc_coefs);

% generate data
data = obj.gen_process(vrc, 'nsamples', p.Results.nsamples);

end