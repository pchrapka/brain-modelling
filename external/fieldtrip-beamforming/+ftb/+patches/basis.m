function patches = basis(patches, leadfield, varargin)
%   Input
%   -----
%   patches (struct array)
%       patch configuration, output of ftb.patches functions, for example
%       ftb.patches.get_aal_coarse
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
%   patches (struct array)
%       patch configuration, with the following updated fields
%   patches.U
%       basis for the patch
%   patches.inside
%       logical index of points inside the patch

p = inputParser;
addRequired(p,'patches',@isstruct);
addRequired(p,'leadfield',@isstruct);
addParameter(p,'eta',0.85);
parse(p,patches,leadfield,varargin{:});

% load the atlas
atlas = ft_read_atlas(patches(1).atlasfile);
atlas = ft_convert_units(atlas,'cm');

% computer basis for each patch
for i=1:length(patches)
    
    % select grid points in anatomical regions that make up the patch
    cfg = [];
    cfg.atlas = atlas;
    cfg.roi = patches(i).labels;
    cfg.inputcoord = 'mni';
    patches(i).inside = ft_volumelookup(cfg, leadfield);
    
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
    
end

end