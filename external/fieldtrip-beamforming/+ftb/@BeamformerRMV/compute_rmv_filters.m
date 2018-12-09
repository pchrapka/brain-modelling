function source = compute_rmv_filters(...
    obj, data, leadfield, varargin)
%COMPUTE_RMV_FILTERS computes filters for an RMV beamformer that
%operates on patches instead of point sources
%   [source] = COMPUTE_RMV_FILTERS(data, leadfield, patch_model, ...)
%   computes filters for an RMV beamformer that operates on patches
%   instead of point sources. This is useful for coarse beamforming.
%
%   Input
%   -----
%   data (struct)
%       timelocked EEG data, output of ft_timelockanalysis
%   leadfield (struct)
%       leadfields, output of ft_prepare_leadfield
%
%   Parameters
%   ----------
%   fixedori (default = true)
%       fixed moment orientation, chooses the moment that maximizes the
%       power of the beamformer
%
%       NOTE fixedori = false is not implemented
%   mode (default = 'all')
%       mode of operation, chooses how many grid points are set for the
%       beamforming step
%       all - all points inside a patch are selected and contain the patch
%       filter (useful for plotting)
%       single - one point inside a patch is selected and contains the
%       patch filter (useful for saving memory)
%   
%   Output
%   ------
%   source (struct)
%       struct containing spatial filters
%   source.inside (cell array)
%       index specifying which grid points are to be evaluated
%   source.filters (cell array)
%       beamforming filter for each point in the leadfield grid, to be
%       specified as precomputed filters in ft_sourceanalysis


p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'leadfield',@isstruct);
addParameter(p,'fixedori',true,@islogical);
addParameter(p,'mode','all',@(x) any(validatestring(x,{'all','single'})));
% add options
parse(p,data,leadfield,varargin{:});

% allocate mem
source = [];
source.filters = cell(size(leadfield.leadfield));
source.inside = leadfield.inside;

% NOTE when supplying ft_sourceanalysis with filters, i can only specify
% one per grid point, not per trial, so this function can only operate on a
% single covariance

% check number of covariance repetitions
ndims_cov = length(size(data.cov));
if ndims_cov == 3
    ntrials = size(data.cov,1);
else
    ntrials = 1;
end

if ntrials > 1
    error('can only precompute filters with one cov, use singletrial option in BeamformerRMV');
end

fprintf('computing filters...\n');
% computer filter for each inside point
% TODO is inside boolean or an index
for i=1:length(leadfield.leadfield)
    if ~leadfield.inside(i)
        source.filters{i} = [];
    else
        % Set up cfg
        cfg_rmv = [];
        % TODO check type of leadfield
        cfg_rmv.H = leadfield.leadfield(leadfield.inside(i));
        cfg_rmv.R = data.cov;
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
                nchannels = size(data.cov,1);
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
        data_out = aet_analysis_rmv(cfg_rmv);
        % TODO double check that it 3xN
        source.filter{i} = data_out.W;
    end
    
end

end