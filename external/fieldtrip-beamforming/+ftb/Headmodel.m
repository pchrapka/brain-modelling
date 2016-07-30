classdef Headmodel < ftb.AnalysisStep
    %Headmodel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = protected)
        config;
        mri_headmodel;
    end
    
    methods
        function obj = Headmodel(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
            % set vars
            obj@ftb.AnalysisStep('HM');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            obj.mri_headmodel = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.MRI'));
            parse(p,prev);
            
            % set the previous step, aka MRI
            obj.prev = p.Results.prev;
        end
        
        function obj = init(obj,analysis_folder)
            %INIT initializes the output files
            %   INIT(analysis_folder)
            %
            %   Input
            %   -----
            %   analysis_folder (string)
            %       root folder for the analysis output
            
            % init output folder and files
            obj.mri_headmodel = obj.init_output(analysis_folder,...
                'properties',{'mri_headmodel'});
            
            obj.init_called = true;
            
            % load any files specified in the config
            obj.load_files();
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            mriObj = obj.get_dep('ftb.MRI');
            
            if obj.check_file(obj.mri_headmodel)
                % Create the head model from the segmented data
                cfgin = obj.config.ft_prepare_headmodel;
                data = ftb.util.loadvar(mriObj.mri_mesh);
                
                vol = ft_prepare_headmodel(cfgin, data);
                
                % convert units
                if isfield(obj.config,'units')
                    fprintf('%s: converting units to %s\n',...
                        strrep(class(obj),'ftb.',''), obj.config.units);
                    vol = ft_convert_units(vol, obj.config.units);
                end
                
                save(obj.mri_headmodel, 'vol');
            else
                fprintf('%s: skipping ft_prepare_headmodel, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
        
        function result = get_mesh(obj, type, varargin)
            %GET_MESH returns mesh for selected surface
            %   GET_MESH(ojb, type, [units])
            %
            %   Input
            %   -----
            %   type (string)
            %       scalp,skull,brain
            %   units (string, optional, default = 'cm')
            %       mm, cm
            
            % parse inputs
            p = inputParser;
            addRequired(p,'type',@(x) any(validatestring(x,{'scalp','skull','brain'})));
            addOptional(p,'units','cm', @(x) any(validatestring(x,{'mm','cm'})));
            parse(p,type,varargin{:});
            
            % load data
            vol = ftb.util.loadvar(obj.mri_headmodel);
            % convert to mm
            vol = ft_convert_units(vol, p.Results.units);
            
            switch p.Results.type
                case 'scalp'
                    switch vol.type
                        case 'bemcp'
                            result = vol.bnd(3);
                        case 'dipoli'
                            result = vol.bnd(1);
                        case 'openmeeg'
                            idx = vol.skin_surface;
                            result = vol.bnd(idx);
                        case 'concentricspheres'
                            warning('no mesh for concentricspheres');
                            result = [];
                        otherwise
                            error(['ftb:' mfilename],...
                                'Which one is the scalp?');
                    end
                case 'skull'
                    error('implement me');
                case 'brain'
                    error('implement me');
            end
            
        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'scalp'
            %       'skull'
            %       'brain'
            %       can also include elements from previous stages
            
            unit = 'mm';
            
            for i=1:length(elements)
                switch elements{i}
                    case 'scalp'
                        hold on;
                        
                        % Load data
                        vol = ftb.util.loadvar(obj.mri_headmodel);
                        % Convert to mm
                        vol = ft_convert_units(vol, unit);
                        
                        style = {'edgecolor','none','facealpha',0.3,'facecolor','b'};
                        % Plot the scalp
                        switch vol.type
                            case 'bemcp'
                                ft_plot_mesh(vol.bnd(3),style{:});
                            case 'dipoli'
                                ft_plot_mesh(vol.bnd(1),style{:});
                            case 'openmeeg'
                                idx = vol.skin_surface;
                                ft_plot_mesh(vol.bnd(idx),style{:});
                            case 'concentricspheres'
                                [~,idx] = max(vol.r);
                                voltmp = vol;
                                voltmp.r = vol.r(idx);
                                voltmp.cond = vol.cond(idx);
                                ft_plot_vol(voltmp,style{:});
                            otherwise
                                error(['ftb:' mfilename],...
                                    'Which one is the scalp?');
                        end
                        
                    case 'skull'
                        hold on;
                        
                        % Load data
                        vol = ftb.util.loadvar(obj.mri_headmodel);
                        % Convert to mm
                        vol = ft_convert_units(vol, unit);
                        
                        style = {'edgecolor','none','facealpha',0.3,'facecolor','g'};
                        % Plot the skull
                        switch vol.type
                            case {'bemcp','dipoli'}
                                ft_plot_mesh(vol.bnd(2),style{:});
                            case 'openmeeg'
                                if vol.source > vol.skin_surface
                                    idx = vol.skin_surface + 1;
                                else
                                    idx = vol.source + 1;
                                end
                                ft_plot_mesh(vol.bnd(idx),style{:});
                            case 'concentricspheres'
                                idx = 2;
                                voltmp = vol;
                                voltmp.r = vol.r(idx);
                                voltmp.cond = vol.cond(idx);
                                ft_plot_vol(voltmp,style{:});
                            otherwise
                                error(['ftb:' mfilename],...
                                    'Which one is the scalp?');
                        end
                        
                    case 'brain'
                        hold on;
                        
                        % Load data
                        vol = ftb.util.loadvar(obj.mri_headmodel);
                        % Convert to mm
                        vol = ft_convert_units(vol, unit);
                        
                        style = {'edgecolor','none','facealpha',0.3,'facecolor','r'};
                        % Plot the brain
                        switch vol.type
                            case 'bemcp'
                                ft_plot_mesh(vol.bnd(1),style{:});
                            case 'dipoli'
                                ft_plot_mesh(vol.bnd(3),style{:});
                            case 'openmeeg'
                                idx = vol.source;
                                ft_plot_mesh(vol.bnd(idx),style{:});
                            case 'concentricspheres'
                                [~,idx] = min(vol.r);
                                voltmp = vol;
                                voltmp.r = vol.r(idx);
                                voltmp.cond = vol.cond(idx);
                                ft_plot_vol(voltmp,style{:});
                            otherwise
                                error(['ftb:' mfilename],...
                                    'Which one is the brain?');
                        end
                end
            end
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
    
    end
end

