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
        end         
        
        function obj = get_basis(obj,leadfield,varargin)
            
            % load the atlas
            atlas = ft_read_atlas(obj.atlasfile);
            % make sure units are consistent
            atlas = ft_convert_units(atlas,leadfield.unit);
            
            npatches = length(obj.patches);
            for i=1:npatches
                % get the basis for each patch
                obj.patches(i).get_basis(atlas, leadfield);
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