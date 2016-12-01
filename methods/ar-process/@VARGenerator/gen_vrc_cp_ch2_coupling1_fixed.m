function data = gen_vrc_cp_ch2_coupling1_fixed(obj,varargin)

p = inputParser();
parse(p,varargin{:});

% ntrials = obj.nsims;
nchannels = obj.nchannels;

norder = 10;
ntime = 358;

% set VRC processes
k_vrc1 = zeros(norder,1,1);
k_vrc1(1,1,1) = 0.4789;
k_vrc1(6,1,1) = -0.9642;

k_vrc2 = zeros(norder,1,1);
k_vrc2(4,1,1) = 0.6054;
k_vrc2(10,1,1) = 0.9131;

coupling_value = -0.4006;
coupling_order = 3;

% Rationale: for each condition use the same VAR models for the constant
% and pulse processes, change the coupling and changepoints to account for
% the change in condition

% set up 2 1-channel VAR model with random coefficients
vrc1 = VRC(1, norder);
vrc1.coefs_set(k_vrc1, k_vrc1);

vrc2 = VRC(1, norder);
vrc2.coefs_set(k_vrc2, k_vrc2);

source_channels = randsample(1:nchannels,2);

% set const to vrc 1
vrc_const = zeros(norder, nchannels, nchannels);
vrc_const(:,source_channels(1),source_channels(1)) = vrc1.Kf;

% set pulse to vrc 2
vrc_pulse_source = zeros(norder, nchannels, nchannels);
vrc_pulse_source(:,source_channels(2),source_channels(2)) = vrc2.Kf;

% set changepoints
changepoints = [20 100] + (ntime - 256);

% select coupled channels randomly
coupled_channels = randsample(source_channels,2);

% set up coupling coefficient
vrc_coupling = zeros(norder, nchannels, nchannels);
vrc_coupling(coupling_order,coupled_channels(1),coupled_channels(2)) = coupling_value;
    
% add const and coupling to pulse
vrc_pulse = vrc_const + vrc_coupling + vrc_pulse_source;
    
vrc_constpulse = VRCConstAndPulse(nchannels, norder, changepoints);
    
vrc_constpulse.coefs_set(vrc_const, vrc_const, 'const');
vrc_constpulse.coefs_set(vrc_pulse, vrc_pulse, 'pulse');
    
% check stability
verbosity = false;
stable = vrc_constpulse.coefs_stable(verbosity);
if ~stable
    error('not stable');
end

% generate data
data = obj.gen_process(vrc_constpulse, 'nsamples', ntime);

end