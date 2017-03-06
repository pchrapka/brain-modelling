classdef PatchLabel < ftb.Patch
    
    properties (SetAccess = protected)
        
        % anatomical labels that make up the patch, each patch contains a
        % mutually exclusive set of labels
        labels;
        
    end
    
    methods
        function obj = PatchLabel(name,labels)
            % Patch constructor
            %   Patch(name, labels) construct Patch object
            %
            %   Input
            %   -----
            %   name (string)
            %       patch name
            %   labels (cell array)
            %       list of atlas labels belonging to the patch
            
            p = inputParser();
            addRequired(p,'name',@ischar);
            addRequired(p,'labels',@iscell);
            parse(p,name,labels);
            
            obj@ftb.Patch(name);
            
            obj.labels = p.Results.labels;
            
        end
        
        function mask = get_mask(obj,atlas,leadfield,varargin)
            %GET_MASK create mask for PatchLabel
            
            p = inputParser;
            addRequired(p,'atlas',@isstruct);
            addRequired(p,'leadfield',@isstruct);
            parse(p,atlas,leadfield,varargin{:});
            
            cfg = [];
            cfg.atlas = atlas;
            cfg.inputcoord = atlas.coordsys;
            cfg.roi = obj.labels;
            
            mask = ft_volumelookup(cfg, leadfield);
        end
    end
    
end