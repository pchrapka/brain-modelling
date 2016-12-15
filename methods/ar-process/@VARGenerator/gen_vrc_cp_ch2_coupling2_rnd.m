function [process,nsamples] = gen_vrc_cp_ch2_coupling2_rnd(obj,varargin)
%
%   Parameters
%   ----------
%   time (integer, default = 358)
%       number of samples
%   order (integer, default = 10)
%       model order
%   changepoints (vector, default = [20 100] + (358 - 256))
%       beginning and ending samples of the pulse

p = inputParser();
addParameter(p,'time',358,@isnumeric);
addParameter(p,'order',10,@isnumeric);
addParameter(p,'changepoints',[20 100] + (358 - 256),@isvector);
parse(p,varargin{:});

nchannels = obj.nchannels;

norder = p.Results.order;
ntime = p.Results.time;

% ncoefs = norder;
% sparsity = 0.1;
% ncoefs_sparse = ceil(ncoefs*sparsity);
ncoefs_sparse = 2;

ncouplings = 2;

% Rationale: for each condition use the same VAR models for the constant
% and pulse processes, change the coupling and changepoints to account for
% the change in condition

% set up 2 1-channel VAR model with random coefficients
vrc1 = VRC(1, norder);
vrc1.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,...
    'stable',true,'verbose',1);

vrc2 = VRC(1, norder);
vrc2.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,...
    'stable',true,'verbose',1);

source_channels = randsample(1:nchannels,2);

% set const to vrc 1
vrc_const = zeros(norder, nchannels, nchannels);
vrc_const(:,source_channels(1),source_channels(1)) = vrc1.Kf;

% set pulse to vrc 2
vrc_pulse_source = zeros(norder, nchannels, nchannels);
vrc_pulse_source(:,source_channels(2),source_channels(2)) = vrc2.Kf;

stable = false;
while ~stable
    
    % modify coupling for each condition
    vrc_coupling = zeros(norder, nchannels, nchannels);
    coupling_count = 0;
    while coupling_count < ncouplings
        
        coupled_channels = randsample(source_channels,2);
        coupled_order = randsample(1:norder,1);
        
        % check if we've already chosen this one
        if vrc_coupling(coupled_order,coupled_channels(1),coupled_channels(2)) == 0
            % generate a new coefficient
            vrc_coupling(coupled_order,coupled_channels(1),coupled_channels(2)) = unifrnd(-1, 1);
            % increment counter
            coupling_count = coupling_count + 1;
        end
    end
    
    % add const and coupling to pulse
    vrc_pulse = vrc_const + vrc_coupling + vrc_pulse_source;
    
    vrc_constpulse = VRCConstAndPulse(nchannels, norder, p.Results.changepoints);
    
    vrc_constpulse.coefs_set(vrc_const, vrc_const, 'const');
    vrc_constpulse.coefs_set(vrc_pulse, vrc_pulse, 'pulse');
    
    % check stability
    verbosity = false;
    stable = vrc_constpulse.coefs_stable(verbosity);
    if ~stable
        fprintf('not stable\n');
    end
end

% set outputs
process = vrc_constpulse;
nsamples = ntime;

end
