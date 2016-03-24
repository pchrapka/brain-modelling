function [source, patches] = beamformer_lcmv_patch(...
    data, leadfield, atlasfile, patches, varargin)
%BEAMFORMER_LCMV_PATCH computes filters for an LCMV beamformer that
%operates on patches instead of point sources
%   [source,patches] = BEAMFORMER_LCMV_PATCH(data, leadfield,
%   atlasfile, patches, ...) computes filters for an LCMV beamformer that
%   operates on patches instead of point sources. This is useful for coarse
%   beamforming.
%
%   TODO add reference Limpiti2006
%
%   Input
%   -----
%   data (struct)
%       timelocked EEG data, output of ft_timelockanalysis
%   leadfield (struct)
%       leadfields, output of ft_prepare_leadfield
%   atlasfile (string)
%       atlas file name
%   patches (struct array)
%       patch configuration, output of ftb.patches functions, for example
%       ftb.patches.get_aal_coarse
%
%   Parameters
%   ----------
%   eta (default = 0.85)
%       representation accuracy, ideally should be close to 1 but it will
%       also lose its ability to differentiate other patches and resolution
%       will suffer, see Limpiti2006 for more
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
%
%   patches (struct array)
%       patch configuration, with the following updated fields
%   patches.U
%       basis for the patch
%   patches.inside
%       logical index of points inside the patch


p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'leadfield',@isstruct);
addRequired(p,'atlasfile',@ischar);
addRequired(p,'patches',@isstruct);
addParameter(p,'eta',0.85);
addParameter(p,'fixedori',true,@islogical);
% add options
parse(p,data,leadfield,atlasfile,patches,varargin{:});

% load the atlas
atlas = ft_read_atlas(p.Results.atlasfile);
atlas = ft_convert_units(atlas,'cm');

% allocate mem
source = [];
source.filters = cell(size(leadfield.leadfield));
source.patch_labels = cell(size(leadfield.leadfield));

% computer filter for each patch
for i=1:length(patches)
    
    % select grid points in anatomical regions that make up the patch
    cfg = [];
    cfg.atlas = atlas;
    cfg.roi = patches(i).labels;
    cfg.inputcoord = 'mni';
    patches(i).inside = ft_volumelookup(cfg, leadfield);
    
%     % select grid points inside patch
%     grid_sel = false(size(leadfield.inside));
%     grid_sel(patches(i).inside) = 1;
    
    % get leadfields in patch
    lf_patch = leadfield.leadfield(patches(i).inside);
    % concatenate into a single wide matrix
    % Nx3q, q is number of points
    Hk = [lf_patch{:}];
    patches(i).H = Hk;
    
    % generate basis for patch
    
    % assume Gamma = I, i.e. white noise
    % otherwise 
    %   L = chol(Gamma);
    %   Hk_tilde = L*Hk;
    
    % take SVD of Hk
    % S elements are in decreasing order
    [U,Sk,~] = svd(Hk);
    nsingular = size(Sk,1);
    % select the minimum number of singular values
    for j=1:nsingular
        % NOTE if Gamma ~= I
        %   Uk_tilde = L*Uk;
        
        % select j left singular vectors corresponding to largest singular
        % values
        Uk = U(:,1:j);
        
        % compute the representation accuracy
        gammak = trace(Hk'*(Uk*Uk')*Hk)/trace(Hk'*Hk);
        
        % check if we've reached the threshold
        if gammak > p.Results.eta
            % use the current Uk
            break;
        end
    end
    % save Uk
    patches(i).U = Uk;
    
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