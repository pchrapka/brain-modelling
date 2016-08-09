function data = gen_vrc_cp_ch2_coupling2_rnd(obj,varargin)

p = inputParser();
addParameter(p,'process',[]);
parse(p,varargin{:});

ntrials = obj.nsims;
nchannels = obj.nchannels;

norder = 10;
ntime = 358;

% ncoefs = norder;
% sparsity = 0.1;
% ncoefs_sparse = ceil(ncoefs*sparsity);
ncoefs_sparse = 2;

ncouplings = 2;

if isempty(p.Results.process)
    
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
    vrc_const = zeros(nchannels, nchannels, norder);
    vrc_const(source_channels(1),source_channels(1),:) = vrc1.Kf;
    
    % set pulse to vrc 2
    vrc_pulse_source = zeros(nchannels, nchannels, norder);
    vrc_pulse_source(source_channels(2),source_channels(2),:) = vrc2.Kf;
    
    % set different changepoints for the conditions
    changepoints = [20 100] + (ntime - 256);
    % changepoints = [50 120] + (ntime - 256);
    
    stable = false;
    while ~stable
        
        % modify coupling for each condition
        vrc_coupling = zeros(nchannels, nchannels, norder);
        coupling_count = 0;
        while coupling_count < ncouplings
            
            coupled_channels = randsample(source_channels,2);
            coupled_order = randsample(1:norder,1);
            
            % check if we've already chosen this one
            if vrc_coupling(coupled_channels(1),coupled_channels(2),coupled_order) == 0
                % generate a new coefficient
                vrc_coupling(coupled_channels(1),coupled_channels(2),coupled_order) = unifrnd(-1, 1);
                % increment counter
                coupling_count = coupling_count + 1;
            end
        end
        
        % add const and coupling to pulse
        vrc_pulse = vrc_const + vrc_coupling + vrc_pulse_source;
        
        vrc_constpulse = VRCConstAndPulse(nchannels, norder, changepoints);
        
        vrc_constpulse.coefs_set(vrc_const, vrc_const, 'const');
        vrc_constpulse.coefs_set(vrc_pulse, vrc_pulse, 'pulse');
        
        % check stability
        verbosity = false;
        stable = vrc_constpulse.coefs_stable(verbosity);
        if ~stable
            fprintf('not stable\n');
        end
    end
else
    vrc_constpulse = p.Results.process;
end

% generate data
data = [];
data.process = vrc_constpulse;
data.signal = zeros(nchannels,ntime,ntrials);
data.signal_norm = zeros(nchannels,ntime,ntrials);
for j=1:ntrials
    % simulate process
    [signal,signal_norm,~] = vrc_constpulse.simulate(ntime);
    
    data.signal(:,:,j) = signal;
    data.signal_norm(:,:,j) = signal_norm;
end

% save true coefficients
data.true = vrc_constpulse.get_rc_time(ntime,'Kf');

end