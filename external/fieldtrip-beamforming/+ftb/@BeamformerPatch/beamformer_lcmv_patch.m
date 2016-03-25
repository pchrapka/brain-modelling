function source = beamformer_lcmv_patch(...
    data, leadfield, patches, varargin)
%BEAMFORMER_LCMV_PATCH computes filters for an LCMV beamformer that
%operates on patches instead of point sources
%   [source] = BEAMFORMER_LCMV_PATCH(data, leadfield, patches, ...)
%   computes filters for an LCMV beamformer that operates on patches
%   instead of point sources. This is useful for coarse beamforming.
%
%   TODO add reference Limpiti2006
%
%   Input
%   -----
%   data (struct)
%       timelocked EEG data, output of ft_timelockanalysis
%   leadfield (struct)
%       leadfields, output of ft_prepare_leadfield
%   patches (struct array)
%       patch configuration, output of ftb.patches functions, for example
%       ftb.patches.get_aal_coarse
%
%   Parameters
%   ----------
%   fixedori (default = true)
%       fixed moment orientation, chooses the moment that maximizes the
%       power of the beamformer
%
%       NOTE fixedori = false is not implemented
%   
%   Output
%   ------
%   source (struct)
%       struct containing spatial filters and patch ables
%   source.filters (cell array)
%       beamforming filter for each point in the leadfield grid, to be
%       specified as precomputed filters in ft_sourceanalysis
%   source.patch_labels (cell array)
%       anatomical label for each point in the leadfield grid


p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'leadfield',@isstruct);
addRequired(p,'patches',@isstruct);
addParameter(p,'fixedori',true,@islogical);
% add options
parse(p,data,leadfield,patches,varargin{:});

% allocate mem
source = [];
source.filters = cell(size(leadfield.leadfield));
source.patch_labels = cell(size(leadfield.leadfield));

% computer filter for each patch
for i=1:length(patches)

    % get the patch basis
    Uk = patches(i).U;
    
    Yk = Uk'*pinv(data.cov)*Uk;
    
    % check what to do about unknown moment
    if p.Results.fixedori
        % if the moment orientation is unknown, maximize the power
        % ordered from smallest to largest
        [V,D] = eig(Yk);
        d = diag(D);
        [~,idx] = sort(d(:),1,'ascend');
        % select the eigenvector corresponding to the smallest eigenvalue
        vk = V(:,idx(1)); 
        
        % compute patch filter weights
        filter = pinv(vk'*Yk*vk)*pinv(data.cov)*Uk*vk;
        filter = filter';
    else
        % NOTE Not sure what to do if it's not true
        % You're limited to j moments
        % They're not x,y,z anymore because we changed the basis
        error('are you sure about this?');
        
        % compute patch filter weights
        filter = pinv(Yk)*Uk'*pinv(data.cov);
    end
    
    % set patch filter at each point in patch
    [source.filters{patches(i).inside}] = deal(filter);
    % NOTE Redundant, but it keeps everything else in Fieldtrip working
    % as normal
    
    % save patch label for each point
    [source.patch_labels{patches(i).inside}] = deal(patches(i).name);
    
end

% set empty filters to zero

% check which filters are empty
grid_empty = cellfun('isempty',source.filters);
% select those that are inside only
grid_empty = grid_empty' & leadfield.inside;
% create a filter with zeros
filter = zeros(size(filter));
[source.filters{grid_empty}] = deal(filter);

% check which labels are empty
grid_empty = cellfun('isempty',source.patch_labels);
[source.patch_labels{grid_empty}] = deal('');

end