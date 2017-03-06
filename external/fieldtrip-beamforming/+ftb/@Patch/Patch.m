classdef Patch < handle
    
    properties (SetAccess = protected)
        % name of patch
        name;
        
        % anatomical labels that make up the patch, each patch contains a
        % mutually exclusive set of labels
        labels;
        
        inside;
        centroid;
        
        U;
        H;
    end
    
    methods
        function obj = Patch(name,labels)
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
            
            obj.name = p.Results.name;
            obj.labels = p.Results.labels;
            
            obj.inside = [];
            obj.centroid = [];
            obj.U = [];
            obj.H = [];
            
        end
        
        obj = get_basis(obj,atlas,leadfield,varargin);
    end
    
end