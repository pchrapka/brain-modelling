function [process,nsamples] = gen_vrc_sparsechannels_coupling_rnd(obj,varargin)
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
addParameter(p,'nsparsechannels',1,@isnumeric);
parse(p,varargin{:});

if p.Results.nsparsechannels == obj.nchannels
    error('select less channels');
end

nchannels = obj.nchannels;
norder = p.Results.order;

ncoefs = (nchannels^2)*norder;
ncoefs_channel = ceil(p.Results.channel_sparsity*norder);

ncoefs_coupling = (p.Results.nsparsechannels^2)*norder - p.Results.nsparsechannels*norder;
ncoupling = ceil(p.Results.coupling_sparsity*ncoefs_coupling);

stable = false;
flag_restart = false;
while ~stable || flag_restart
    
    vrc_full = VRC(nchannels, norder);
    vrc_full.coefs_gen_sparse(...
        'structure','fullchannels',...
        'mode','exact',...
        'ncoefs',ncoefs_channel*nchannels,...
        'ncouplings',0,...
        'stable',true,...
        'max_order',true,...
        'verbose',1);
    
    % create mask
    channel_idx = randsample(1:obj.nchannels,p.Results.nsparsechannels);
    mask = false(size(vrc_full.Kf));
    for i=channel_idx
        for j=channel_idx
            if i~=j
                mask(:,i,j) = true(norder,1);
            end
        end
    end
    
    % generate couplings
    stable_coupling = vrc_full.coefs_gen_coupling(mask,'ncouplings',ncoupling);
    
    if ~stable_coupling
        flag_restart = true;
    end
    
    % check stability
    stable1 = vrc_full.coefs_stable(false,'method','ar');
    stable2 = vrc_full.coefs_stable(false,'method','sim');
    stable = stable1 && stable2;
    
    if ~stable
        vrc_full.coefs_stable(true,'method','ar');
        vrc_full.plot();
        drawnow;
    end
end

process = vrc_full;
nsamples = p.Results.nsamples;

end