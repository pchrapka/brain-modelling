function [process,nsamples] = gen_vrc_full_coupling_rnd(obj,varargin)
%gen_vrc_full_coupling_rnd generates a stationary VRC model
%   gen_vrc_full_coupling_rnd(obj, ...)
%
%   Generates a stationary VRC model with the following characteristics:
%   - each channel is a sparse VRC process
%   - there is a specific level of channel coefficient sparsity
%   - there is a specific level of coupling coefficient sparsity
%   - there is at least one coefficient in the max order specified

p = inputParser();
addParameter(p,'nsamples',2000,@isnumeric);
addParameter(p,'order',10,@isnumeric);
addParameter(p,'channel_sparsity',0.4,@(x) isnumeric(x) && ((x > 0) && (x <= 1)));
addParameter(p,'coupling_sparsity',0.1,@(x) isnumeric(x) && ((x > 0) && (x <= 1)));
parse(p,varargin{:});

nchannels = obj.nchannels;
norder = p.Results.order;

ncoefs = (nchannels^2)*norder;
ncoefs_coupling = ncoefs - nchannels*norder;

ncoupling = ceil(p.Results.coupling_sparsity*ncoefs_coupling);
ncoefs_channel = ceil(p.Results.channel_sparsity*norder);

vrc_full = VRC(nchannels, norder);
vrc_full.coefs_gen_sparse(...
    'structure','fullchannels',...
    'mode','exact',...
    'ncoefs',ncoefs_channel*nchannels + ncoupling,...
    'ncouplings',ncoupling,...
    'stable',true,...
    'max_order',true,...
    'verbose',1);

process = vrc_full;
nsamples = p.Results.nsamples;

end