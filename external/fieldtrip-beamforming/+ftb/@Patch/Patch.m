classdef Patch < handle
    
    properties (SetAccess = protected)
        % name of patch
        name;
        
        inside;
        centroid;
        
        U;
        H;
    end
    
    methods
        function obj = Patch(name)
            % Patch constructor
            %   Patch(name, labels) construct Patch object
            %
            %   Input
            %   -----
            %   name (string)
            %       patch name
            
            p = inputParser();
            addRequired(p,'name',@ischar);
            parse(p,name);
            
            obj.name = p.Results.name;
            
            obj.inside = [];
            obj.centroid = [];
            obj.U = [];
            obj.H = [];
            
        end
        
        obj = get_basis(obj,atlas,leadfield,varargin);
    end
        
    methods (Abstract)
        mask = get_mask(obj,atlas,leadfield,varargin);
    end
    
end