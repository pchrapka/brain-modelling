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
filters = cell(size(leadfield.leadfield));

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
% compute filter for each inside point
R = data.cov;
idx_inside = leadfield.inside;
H_all = leadfield.leadfield;

npoints = length(leadfield.leadfield);
progbar = ProgressBar(npoints);
parfor i=1:npoints
% for i=1:npoints
    progbar.progress();
    if idx_inside(i)
        data_out = obj.compute_rmv_filters_inner(R, H_all{i});
        if ~isequal(data_out.status,'Solved')
            fprintf('RMV Error: index %d - %s%s',i,data_out.info.info,repmat(' ',1,90));
        end
        % Filter dims: 3xN
        filters{i} = data_out.W';
    else
        filters{i} = [];
    end
end
progbar.stop();

% allocate mem
source = [];
source.filters = filters;
source.inside = leadfield.inside;

end

