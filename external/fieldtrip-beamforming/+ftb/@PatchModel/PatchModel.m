classdef PatchModel < handle
    
    properties (SetAccess = protected)
        
        % atlas file name
        atlasfile;
        
        % list of ftb.Patch objects
        patches;
    end
    
    methods
        
        function obj = PatchModel(modelname,varargin)
            % PatchModel
            
            p = inputParser();
            addRequired(p,'modelname',@ischar);
            addParameter(p,'params',{},@iscell);
            addParameter(p,'sphere_patch',{},@iscell);
            parse(p,modelname,varargin{:});
            
            obj.atlasfile = '';
            obj.patches = [];
            
            switch modelname
                case 'aal-coarse-19'
                    obj.get_aal_coarse_19(p.Results.params{:});
                case 'aal-coarse-13'
                    obj.get_aal_coarse_13(p.Results.params{:});
                case 'aal'
                    obj.get_all(p.Results.params{:});
                otherwise
                    error('unknown cortical patch config: %s\n',modelname);
            end
            
            if ~isempty(p.Results.sphere_patch)
                if iscell(p.Results.sphere_patch{1})
                    % multiple sphere patches
                    npatches = length(p.Results.sphere_patch);
                    params = p.Results.sphere_patch;
                else
                    npatches = 1;
                    params = {p.Results.sphere_patch};
                end
                
                
                for i=1:npatches
                    params_cur = params{i};
                    
                    patch = PatchSphere(params_cur{:});
                    obj.add_patch(patch);
                end
            end
        end         
        
        function obj = get_basis(obj,leadfield,varargin)
            
            p = inputParser;
            addRequired(p,'leadfield',@isstruct);
            parse(p,leadfield,varargin{:});
            
            % load the atlas
            atlas = ft_read_atlas(obj.atlasfile);
            % make sure units are consistent
            atlas = ft_convert_units(atlas,leadfield.unit);
            
            % set up mask to deal with spherical patches, need to make the
            % rest of the patches mutually exclusive
            mask_temp = obj.patches(1).get_basis(atlas, leadfield);
            mask_sphere = false(size(mask_temp));
            clear mask_temp;
            
            % loop through patches
            npatches = length(obj.patches);
            for i=1:npatches
                % get the basis for each patch
                mask = obj.patches(i).get_basis(atlas, leadfield,'mask',mask_sphere);
                
                if isa(obj.patches(i),'ftb.PatchSphere')
                    % add the mask to the sphere mask
                    mask_sphere = mask_sphere | mask;
                end
            end
            
        end
        
    end
    
    methods (Access = protected)
        
        obj = get_aal_coarse_19(obj,varargin);
        obj = get_aal_coarse_13(obj,varargin);
        
        function obj = add_patch(obj,patch)
            % add_patch add an ftb.Patch object to the patches list
            p = inputParser();
            addRequired(p,'patch',@(x) isa(x,'ftb.Patch'));
            parse(p,patch);
            
            npatches = length(obj.patches);
            obj.patches(npatches+1) = patch;
        end
    end
    
end