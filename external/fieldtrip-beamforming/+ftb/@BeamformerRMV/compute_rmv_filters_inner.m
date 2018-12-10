function filter = compute_rmv_filters_inner(obj, R, H)
% Set up cfg
cfg_rmv = [];
cfg_rmv.H = H;
cfg_rmv.R = R;
cfg_rmv.verbosity = obj.verbosity;
cfg_rmv.solver = obj.solver;
cfg_rmv.eigenspace = obj.eig_type;
cfg_rmv.n_interfering_sources = obj.n_interfering_sources;

if obj.aniso
    % Copy/compute the uncertainty matrix
    % TODO set up uncertainty
    error('user defined uncertainty matrices not implemented');
else
    if obj.epsilon > 0
        % Set up A for isotropic
        nchannels = size(R,1);
        ndims = 3;
        
        epsilon_vec = ones(ndims,1)*sqrt(obj.epsilon^2/ndims);
        A = cell(ndims,1);
        for i=1:ndims
            A{i} = epsilon_vec(i,1)*eye(nchannels);
        end
        
        % Copy the uncertainty matrix
        cfg_rmv.A = A;
    else
        error('epsilon not set');
    end
end

% Run beamformer
data_out = ftb.BeamformerRMV.compute_rmv_filter(cfg_rmv);
% Filter dims: 3xN
filter = data_out.W';
end