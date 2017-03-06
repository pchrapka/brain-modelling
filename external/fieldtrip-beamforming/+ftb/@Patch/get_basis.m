function patches = get_basis(obj, atlas, leadfield, varargin)
%GET_BASIS returns the basis for each patch
%   GET_BASIS(patches, leadfield, ...) returns the basis for each patch
%
%   Input
%   -----
%   atlas (struct)
%       atlas struct, output of ft_read_atlas
%   leadfield (struct)
%       leadfields, output of ft_prepare_leadfield
%
%   Parameters
%   ----------
%   eta (default = 0.85)
%       representation accuracy, ideally should be close to 1 but it will
%       also lose its ability to differentiate other patches and resolution
%       will suffer, see Limpiti2006 for more
%
%   Output
%   ------
%   updates the following fields
%   U
%       basis for the patch
%   H
%       concatenated lead fields
%   inside
%       logical index of points inside the patch
%   centroid
%       centroid of patch points

p = inputParser;
addRequired(p,'atlas',@isstruct);
addRequired(p,'leadfield',@isstruct);
addParameter(p,'eta',0.85);
parse(p,atlas,leadfield,varargin{:});

% make sure leadfield and atlas have same units
atlas = ft_convert_units(atlas,leadfield.unit);

debug = false;

% select grid points in anatomical regions that make up the patch
cfg = [];
cfg.atlas = atlas;
cfg.roi = obj.labels;
cfg.inputcoord = 'mni';
mask = ft_volumelookup(cfg, leadfield);
obj.inside = leadfield.inside & mask(:);

if debug
    figure;
    % plot all inside points
    ft_plot_mesh(leadfield.pos(leadfield.inside,:),'vertexcolor','g');
    hold on;
    % plot patch points
    ft_plot_mesh(leadfield.pos(mask,:));
    
    figure;
    % plot all inside points
    ft_plot_mesh(leadfield.pos(leadfield.inside,:),'vertexcolor','g');
    hold on;
    % plot inside patch points
    ft_plot_mesh(leadfield.pos(leadfield.inside & mask(:),:));
end

% get leadfields in patch
lf_patch = leadfield.leadfield(obj.inside);
% concatenate into a single wide matrix
% Nx3q, q is number of points
Hk = [lf_patch{:}];
obj.H = Hk;

% generate basis for patch

% assume Gamma = I, i.e. white noise
% otherwise
%   L = chol(Gamma);
%   Hk_tilde = L*Hk;

% take SVD of Hk
% S elements are in decreasing order
[U,Sk,~] = svd(Hk);
nsingular = size(Sk,1);
Uk = [];
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
obj.U = Uk;

% compute centroid
locs = leadfield.pos(obj.inside,:);
obj.centroid =  mean(locs,1);

end