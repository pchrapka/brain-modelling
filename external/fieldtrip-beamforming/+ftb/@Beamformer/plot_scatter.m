function plot_scatter(obj, cfg)
%PLOT_SCATTER plots the source power as a sphere at each leadfield
%location
%   PLOT_SCATTER(obj,cfg) plots the source power as a sphere at each
%   leadfield location
%
%   cfg (struct)
%       config struct with the following fields
%   cfg.method (strings)
%       method of visualization, available options:
%       'all'
%       'outer'
%       'plane'
%
%   additional fields
%   cfg.outer (struct)
%   cfg.outer.size
%
%   cfg.plane (struct)
%   cfg.plane.axis
%       select axis for plane: x, y or z
%   cfg.plane.value
%       plane location in axis
%
%   obj 
%       ftb.Beamformer object

if ~isfield(cfg, 'method'), cfg.method = 'all'; end

if isequal(cfg.method, 'outer')
    if ~isfield(cfg, 'outer'), cfg.outer = []; end
    if ~isfield(cfg.outer,'size'), cfg.outer.size = 20; end
end

if isequal(cfg.method, 'plane')
    if ~isfield(cfg, 'plane'), cfg.plane = []; end
    if ~isfield(cfg.plane,'axis'), cfg.plane.axis = 'x'; end
    if ~isfield(cfg.plane,'value'), cfg.plane.value = 0; end
end

% Plot the brain and dipole
dsObj = obj.prev;
elements = {'brain'};
dsObj.plot(elements);


% Plot the leadfield with source analysis results
hold on;
lfObj = obj.get_dep('ftb.Leadfield');
% load leadfield
leadfield = ftb.util.loadvar(lfObj.leadfield);
% dipole is in mm
% Convert leadfield to mm
leadfield = ft_convert_units(leadfield, 'mm');

% load bf data
source = ftb.util.loadvar(obj.sourceanalysis);

% if isfield(cfg, 'contrast')
%     % Load noise source
%     cfgcopy = cfg;
%     cfgcopy.stage.dipolesim = cfg.contrast;
%     cfgtmp = ftb.get_stage(cfgcopy);
%     cfgnoise = ftb.load_config(cfgtmp.stage.full);
%     source_noise = ftb.util.loadvar(cfgnoise.files.ft_sourceanalysis.all);
%     
%     % Contrast
%     source.avg.pow = source.avg.pow ./ source_noise.avg.pow - 1;
% end

% Get data for inside the head
source_inside = source.avg.pow(source.inside);
lfpos_inside = leadfield.pos(leadfield.inside,:);

% % Sort according to
% [source_inside, idx] = sort(source_inside);
% lfpos_inside = lfpos_inside(idx,:);

switch cfg.method
    
    case 'outer'
        % Get data outside a certain range
        idx = zeros(size(lfpos_inside,1),1);
        components = size(lfpos_inside,2);
        for i=1:components
            compmax = max(lfpos_inside(:,i));
            compmin = min(lfpos_inside(:,i));
            
            limitmax = compmax - cfg.outer.size;
            limitmin = compmin + cfg.outer.size;
            
            compidx = (lfpos_inside(:,i) > limitmax) | (lfpos_inside(:,i) < limitmin);
            
            idx = idx | compidx;
            
        end
        
        source_inside = source_inside(idx);
        lfpos_inside = lfpos_inside(idx,:);
    case 'plane'
        % Get data in a plane
        axis_component_map = [];
        axis_component_map.x = 1;
        axis_component_map.y = 2;
        axis_component_map.z = 3;
        
        component = axis_component_map.(cfg.plane.axis);
        
        idx = lfpos_inside(:,component) == cfg.plane.value;
        
        source_inside = source_inside(idx);
        lfpos_inside = lfpos_inside(idx,:);
    case 'all'
    otherwise
        error(['ftb:' mfilename],...
            'unknown method %s', cfg.method);
end

markersize = 100;
scatter3(...
    lfpos_inside(:,1),...
    lfpos_inside(:,2),...
    lfpos_inside(:,3),...
    markersize*source_inside/max(source_inside),...
    source_inside,...
    'filled');
colormap(jet);
colorbar;
    

% Plot inside points
% scatter3(...
%     leadfield.pos(leadfield.inside,1),...
%     leadfield.pos(leadfield.inside,2),...
%     leadfield.pos(leadfield.inside,3), 'k.');
end