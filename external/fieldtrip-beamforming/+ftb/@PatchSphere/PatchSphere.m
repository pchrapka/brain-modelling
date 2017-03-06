classdef PatchSphere < ftb.Patch
    
    properties (SetAccess = protected)
        
        % center of sphere
        center;
        % radius of sphere
        radius;
        
    end
    
    methods
        function obj = PatchSphere(name,center,varargin)
            % PatchSphere constructor
            %   PatchSphere(name, varargin) construct Patch object
            %
            %   Input
            %   -----
            %   name (string)
            %       patch name
            %   center (3x1 vector)
            %       coordinates of center of spherical ROI
            %
            %   Parameters
            %   ----------
            %   radius (number, default = 1)
            %       radius of sphere
            
            p = inputParser();
            addRequired(p,'name',@ischar);
            addRequired(p,'center',@(x) isnumeric(x) && length(x) == 3);
            addParameter(p,'radius',1,@isnumeric);
            parse(p,name,center,varargin{:});
            
            obj@ftb.Patch(name);
            
            obj.center = p.Results.center;
            obj.radius = p.Results.radius;
            
        end
        
        function mask = get_mask(obj,atlas,leadfield,varargin)
            %GET_MASK create mask for PatchSphere
            
            p = inputParser;
            addRequired(p,'atlas',@isstruct);
            addRequired(p,'leadfield',@isstruct);
            parse(p,atlas,leadfield,varargin{:});
            
            cfg = [];
            cfg.atlas = atlas;
            cfg.inputcoord = atlas.coordsys;
            cfg.roi = obj.center;
            cfg.round2nearestvoxel = 'yes';
            cfg.sphere = obj.radius;
            
            mask = ft_volumelookup(cfg,leadfield);
        end
    end
    
end