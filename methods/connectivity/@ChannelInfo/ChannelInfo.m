classdef ChannelInfo < handle
    
    properties (SetAccess = protected)
        label;
        coord;
        region;
        region_order;
        hemisphere;
        hemisphere_order;
    end
    
    methods
        function obj = ChannelInfo(label,varargin)
            
            p = inputParser();
            addRequired(p,'label',@iscell);
            addParameter(p,'coord',[],@isnumeric);
            addParameter(p,'region',{},@iscell);
            addParameter(p,'region_order',[],@isnumeric);
            addParameter(p,'hemisphere',{},@iscell);
            addParameter(p,'hemisphere_order',[],@isnumeric);
            parse(p,label,varargin{:});
            
            nlabels = length(p.Results.label);
            
            % check labels and coords
            if ~isempty(p.Results.coord)
                dims_coords = size(p.Results.coord);
                if length(dims_coords) > 2
                    error([mfilename ':InvalidInput'],...
                        'invalid dimensions for coords');
                end
                if dims_coords(2) < 2 || dims_coords(2) > 3
                    disp(dims_coords);
                    error([mfilename ':InvalidInput'],...
                        'invalid dimensions for coords, either 2d or 3d');
                end
                if nlabels ~= dims_coords(1)
                    error([mfilename ':InvalidInput'],...
                        'not enough coords (%d) for labels (%d)',dims_coords(1),nlabels);
                end
            end
            
            obj.label = p.Results.label;
            obj.coord = p.Results.coord;
            
            % adjust coord to 3d
            if ~isempty(obj.coord)
                if size(obj.coord,2) == 2
                    obj.coord(:,3) = zeros(size(obj.coord,1),1);
                end
            end
            
            % check regions
            if ~isempty(p.Results.region)
                % check regions for each label
                if ~isequal(nlabels,length(p.Results.region))
                    error([mfilename ':InvalidInput'],...
                        'not enough regions (%d) for labels (%d)',...
                        length(p.Results.region),nlabels);
                end
                obj.region = p.Results.region;
                
                if ~isempty(p.Results.region_order)
                    % check region order for each region
                    if ~isequal(nlabels,length(p.Results.region_order))
                        error([mfilename ':InvalidInput'],...
                            'not enough region_order (%d) for labels (%d)',...
                            length(p.Results.region_order),nlabels);
                    end
                    obj.region_order = p.Results.region_order;
                end
            end
            
            % check hemispheres
            if ~isempty(p.Results.hemisphere)
                % check regions for each label
                if ~isequal(nlabels,length(p.Results.hemisphere))
                    error([mfilename ':InvalidInput'],...
                        'not enough hemisphere (%d) for labels (%d)',...
                        length(p.Results.hemisphere),nlabels);
                end
                obj.hemisphere = p.Results.hemisphere;
                
                if ~isempty(p.Results.hemisphere_order)
                    % check region order for each region
                    if ~isequal(nlabels,length(p.Results.hemisphere_order))
                        error([mfilename ':InvalidInput'],...
                            'not enough hemisphere_order (%d) for labels (%d)',...
                            length(p.Results.hemisphere_order),nlabels);
                    end
                    obj.hemisphere_order = p.Results.hemisphere_order;
                end
            end
        end
        
        function populate(obj,atlas)
            
            p = inputParser();
            options_atlas = {'default','aal','aal-coarse-13','aal-coarse-19'};
            addRequired(p,'atlas',@(x) any(validatestring(x,options_atlas)));
            parse(p,atlas);
            
            switch p.Results.atlas
                    
                case 'default'
                    % set region order
                    if isempty(obj.region)
                        error([mfilename ':NoInformation'],...
                            'region is empty\n');
                    else
                        % no region order
                        obj.set_order('region');
                    end
                    
                    % set hemisphere order
                    if isempty(obj.hemisphere)
                        error([mfilename ':NoInformation'],...
                            'hemisphere is empty\n');
                    else
                        % no hemisphere order
                        obj.set_order('hemisphere');
                    end
                    
                otherwise
                    % populate region
                    prop = 'region';
                    if isempty(obj.(prop))
                        results = obj.get_atlas_region(atlas);
                        obj.(prop) = {results.name};
                        
                        prop2 = 'region_order';
                        if isempty(obj.(prop2))
                            obj.(prop2) = [results.order];
                        else
                            warning([mfilename ':AlreadySet'],...
                                '%s already set\n',prop2);
                        end
                    else
                        warning([mfilename ':AlreadySet'],...
                            '%s already set\n',prop);
                    end
                    
                    % populate hemis
                    prop = 'hemisphere';
                    if isempty(obj.(prop))
                        results = obj.get_hemi(atlas);
                        obj.(prop) = {results.name};
                        
                        prop2 = 'hemisphere_order';
                        if isempty(obj.(prop2))
                            obj.(prop2) = [results.order];
                        else
                            warning([mfilename ':AlreadySet'],...
                                '%s already set\n',prop2);
                        end
                    else
                        warning([mfilename ':AlreadySet'],...
                            '%s already set\n',prop);
                    end
                    
            end
            
        end
    end
    
    methods (Access = protected)
        regions = get_atlas_region(obj,atlas);
        hemis = get_hemi(obj,atlas);
        
        function set_order(obj,prop)
            % so group common regions together
            
            prop2 = [prop '_order'];
            % get unique
            names_unique = unique(obj.(prop));
            % set order
            names_unique_order = 1:length(names_unique);
            
            obj.(prop2) = zeros(length(obj.label),1);
            for i=1:length(names_unique)
                % get idx of regions matching current reiong
                idx = cellfun(@(x) ~isempty(x),strfind(obj.(prop),names_unique{i}));
                % set current region order
                obj.(prop2)(idx) = names_unique_order(i);
            end
        end
        
        function result = isempty_props(obj,props)
            p = inputParser();
            addRequired(p,'props',@iscell);
            parse(p,props);
            
            nprops = length(props);
            result = false(nprops,1);
            
            for i=1:nprops
                prop = props{i};
                result(i) = isempty(obj.(prop));
            end
        end
    end
    
    methods (Static, Access = protected)
        [name,order] = get_atlas_region_aal(label);
        [name,order] = get_atlas_region_aal_coarse_13(label);
        [name,order] = get_atlas_region_aal_coarse_19(label);
        
        [name,order] = get_hemi_aal(label,mode);
    end

end
        