function plot_directed(obj,varargin)
%   Parameters
%   ----------
%   makemovie (logical, default = false)
%       flag to make and save movie
%   threshold (numeric, default = 0)
%       threshold for PDC, connections below this threshold are not plotted
%   pausetime (numeric, default = 0.01)
%       time to pause for each frame, relevant if makemovie = false
%   maxdur (numeric, default = 0.05*nsamples)
%       connection duration is represented by the line width, thus maxdur
%       represents the number of samples for which a connection has to be
%       active to reach the max line width
%   outdir (string)
%       output directory for summary data
%       by default uses output directory set in ViewPDC.outdir, can be
%       overriden here with:
%       1. 'data' - same directory where data is located
%       2. any regular path
%   save (logical, default = false)
%       flag to save summary to data file

obj.save_tag = [];
p = inputParser();
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
addParameter(p,'makemovie',false,@islogical);
addParameter(p,'threshold',0,@isnumeric);
addParameter(p,'pausetime',0.01,@isnumeric);
addParameter(p,'maxdur',0,@isnumeric);
addParameter(p,'layout','default',@(x) any(validatestring(x,{'default','openhemis','circle'})));
parse(p,varargin{:});

obj.save_tag = [];
obj.load();
obj.check_info();

debug = false;

[nsamples,nchannels,~,nfreqs] = size(obj.pdc);

% max durection in units of samples
if p.Results.maxdur == 0
    maxdur = max([1 ceil(0.05*nsamples)]);
    % it should also be at least 1
else
    maxdur = p.Results.maxdur;
end

w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

% copy labels
labels = obj.info.label;

% set up coordinate layout
coord_order = [];
switch p.Results.layout
    case 'default'
        coord = obj.info.coord;
        
        % assume the coords are anatomical, corrected after switch if
        % nothing is given
        axislim_multiple = 1.1;
        fig_size = get(0,'screensize');
        
    case 'circle'
        % ignore obj.info.coord
        coord = [];
    
        if ~isempty(obj.info.coord)
            coord = zeros(nchannels,3);
            
            % sort by hemisphere, region, angle
            idx = obj.sort_channels();
            
            % set up equally space coordinates for plot 
            % based on ordered idx
            for i=1:nchannels
                angle = -2*pi*(i - 1)./nchannels + pi/2;
                coord(idx(i),:) = [cos(angle), sin(angle), 0];
            end
            coord_order = idx;
            
        end
        
        axislim_multiple = 1.6;
        screen_size = get(0,'screensize');
        square_size = min(screen_size(3:4));
        fig_size = [1 1 square_size square_size];
        
    case 'openhemis'
        axislim_multiple = 1.1;
        fig_size = get(0,'screensize');
        % open hemispheres
        if isempty(obj.info.coord)
            error('no anatomical coordinates specified');
        end
        coord = obj.info.coord;
        
        idx_right = coord(:,1) > 0;
        idx_left = ~idx_right;
        angle = pi/3;
        Rz_ccw = rotZ(angle); % counter clockwise for left
        Rz_cw = rotZ(-angle); % clockwise for right
        
        % rotate the coordinates
        coord_temp(idx_right,:) = coord(idx_right,:)*Rz_cw';
        coord_temp(idx_left,:) = coord(idx_left,:)*Rz_ccw';
        
        % separate the coordinates
        [~,idx_front] = min(coord(:,3));
        %[~,idx_back] = max(coord(:,3));
        front_length = abs(coord(idx_front,3));
        
        offset = 3*front_length;
        nright = sum(idx_right);
        nleft = sum(idx_left);
        coord_temp(idx_right,1) = coord_temp(idx_right,1) + repmat(offset,nright,1);
        coord_temp(idx_left,1) = coord_temp(idx_left,1) + repmat(-offset,nleft,1);
        %coord_temp(idx_left,:) = zeros(nleft,3);
        
        coord = coord_temp;
end

if isempty(coord)
    % set up circular
    coord = zeros(nchannels,3);
    for i=1:nchannels
        coord(i,:) = [cos(2*pi*(i - 1)./nchannels), sin(2*pi*(i - 1)./nchannels) 0];
    end
    
    axislim_multiple = 1.4;
    screen_size = get(0,'screensize');
    square_size = min(screen_size(3:4));
    fig_size = [1 1 square_size square_size];
end

% set up avi file
if p.Results.makemovie
    obj.save_tag = sprintf('-adjacency-%s-thresh%0.2f',p.Results.layout,p.Results.threshold);
    outdir = obj.get_outdir(p.Results.outdir);
    outfile = fullfile(outdir,[obj.get_savefile() '.avi']);
    
    vidobj = VideoWriter(outfile,'Motion JPEG AVI');
    open(vidobj);
end

if debug
    % override fig size
    fig_size = [1 1 1000 600];
end

% set up figure
figure('Position', fig_size);

% format
hold on;
axis equal;
axis off;

if debug
    axis on;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    scatter3(0,0,0,100,'filled','or');
end

if sum(coord(:,3)) == 0
    type = '2d';
    ncoord_dim = 2;
else
    type = '3d';
    view([0 45]);
    ncoord_dim = 3;
end

% set up colormap
value_max = length(freq_idx);
cmap = colormap(hot);
cmap = flipdim(cmap,1);
colormap(cmap);
ncolors = size(cmap,1);
colorbar('Location','EastOutside');

% set x,y,z limits
lim_func = {'xlim','ylim','zlim'};
for i=1:ncoord_dim
    dimmin = min(coord(:,i));
    dimmax = max(coord(:,i));
    
    fh = str2func(lim_func{i});
    fh(axislim_multiple*[dimmin dimmax]);
end

% add circle
width = 0;
if ~isempty(obj.info.region)
    width = 0.05;
    add_regions(obj,obj.info,coord,p.Results.layout,coord_order,width);
end

% add labels
offset = width + 0.02;
add_labels(labels,coord,p.Results.layout,type,offset);

% add decorator for coordinates
switch p.Results.layout
    case {'openhemis','default'}
        scatter3(coord(:,1),coord(:,2),coord(:,3),50,'filled','ob');
    case 'circle'
        % do nothing
end

conns = struct('q',[],'ndur',num2cell(zeros(nchannels,nchannels)));
for s=1:nsamples
    % get pdc
    adj_mat1 = squeeze(obj.pdc(s,:,:,freq_idx)); 
    % threshold
    adj_mat1(adj_mat1 < p.Results.threshold) = 0;
    % collapse frequency dimension
    adj_mat = sum(adj_mat1,3);
    %disp(adj_mat);
    
    % plot
    % from j to i
    for j=1:nchannels
        for i=1:nchannels
            if i == j
                % skip the diagonal
                continue;
            end
            
            if adj_mat(j,i) > 0
                % increment duration of connection
                conns(j,i).ndur = conns(j,i).ndur + 1;
                
                % determine connection strength
                % -> represented by color
                pct = adj_mat(j,i)/value_max;
                color_idx = ceil(ncolors*pct);
                
                scaling = 0;
                
                % determine connection duration 
                % -> represented as line width
                dur_pct = max([1/maxdur conns(j,i).ndur/maxdur]);
                linewidth_pct = min([1 dur_pct]); % limit between [0 1]
                maxwidth = 5;
                linewidth = maxwidth*linewidth_pct;
                
                if isempty(conns(j,i).q) 
                    switch p.Results.layout
                        case 'circle'
                            hyp = hyperbola_directed(...
                                coord(j,1:2),coord(i,1:2),...
                                'a',0.5,...
                                'arrowlength',10);
                            conns(j,i).q(1) = plot(hyp(:,1),hyp(:,2),...
                                'Color',cmap(color_idx,:),...
                                'LineWidth',linewidth);
                           
                        otherwise
                            % new quiver
                            dx = coord(i,1) - coord(j,1);
                            dy = coord(i,2) - coord(j,2);
                            dz = coord(i,3) - coord(j,3);
                            
                            conns(j,i).q = quiver3(...
                                coord(j,1),coord(j,2),coord(j,3),...
                                dx,dy,dz,scaling,...
                                'Color',cmap(color_idx,:),...
                                'LineWidth',linewidth);
                    end
                else
                    % update quiver
                    % color and line width
                    nqs = length(conns(j,i).q);
                    for k=1:nqs
                        set(conns(j,i).q(k),...
                            'Color',cmap(color_idx,:),...
                            'LineWidth',linewidth);
                    end
                end
            else
                % delete quiver
                if ~isempty(conns(j,i).q)
                    nqs = length(conns(j,i).q);
                    for k=1:nqs
                        delete(conns(j,i).q(k));
                    end
                    conns(j,i).q = [];
                    conns(j,i).ndur = 0;
                end
            end
        end
    end
    
    % add actual time or sample
    if isempty(obj.time)
        h = title(sprintf('sample: %d',s));
        set(h,'FontSize',12,'FontName','Arial');
    else
        h = title(sprintf('time: %0.0fms',obj.time(s)*1000));
        set(h,'FontSize',12,'FontName','Arial');
    end
    
    if p.Results.makemovie
        % save frame for movie
        drawnow;
        frame = getframe(gcf);
        writeVideo(vidobj,frame);
    else
        drawnow;
        pause(p.Results.pausetime);
    end
end

if p.Results.makemovie
    close(vidobj);
end

end

function Rz = rotZ(angle)
% rotation around the z axis, + angle is counterclockwise
Rz = [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1];
end

function hyp = hyperbola_directed(pt1,pt2,varargin)
% hyperbola travels from pt1 to pt2
p = inputParser();
addRequired(p,'pt1',@(x) length(x) == 2);
addRequired(p,'pt2',@(x) length(x) == 2);
addParameter(p,'a',0.5,@isnumeric);
addParameter(p,'arrowlength',5,@isnumeric);
%addParameter(p,'origin',[0 0],@(x) length(x) == 2);
% assuming hyperparabola is at origin
parse(p,pt1,pt2,varargin{:});

debug = false;

% reshape points
pt1 = reshape(pt1,1,2);
pt2 = reshape(pt2,1,2);
origin = [0 0];
pts = [pt1; pt2; origin];

if debug
    h = [];
    k = 1;
    h(k) = plot(pts(:,1),pts(:,2),'ro','LineWidth',2);
    k = k+1;
end

% rotate so that mid angle is along the x axis
angle1 = atan2(pt1(2),pt1(1));
angle2 = atan2(pt2(2),pt2(1));
anglediff = angle2-angle1;
anglemid = anglediff/2 + angle1;
Rz = @(angle) [cos(angle) -sin(angle); sin(angle) cos(angle)];
pts_mod = pts*Rz(-anglemid)';

if debug
    h(k) = plot(pts_mod(:,1),pts_mod(:,2),'bo','LineWidth',2);
    k=k+1;
end

% a is free to specify
if abs(anglediff) >= pi/2 && abs(anglediff) <= 3*pi/2
    % let longer arcs pass closer to center
    a = 0.2;
else
    a = p.Results.a;
end

% make sure that b is real
if pts_mod(1,1)^2 < 2*a^2
    a = sqrt(0.5)*pts_mod(1,1);
end
% fit b to points
b = sqrt(a^2*pts_mod(1,2)^2/(pts_mod(1,1)^2- a^2));

% compute hyperbola
x = linspace(0,pts_mod(1,1))';
y = sqrt((b^2)*(x.^2/a^2 - 1));
idx = ~(angle(y) == 0);
if sum(idx) == 100
    error('all points are imaginary');
end
x(idx) = [];
y(idx) = [];
hyp_mod = [flipdim([x y],1); x -y];
% y = linspace(0,pts_mod(1,2))';
% x = sqrt(a^2*(1+y.^2/b^2));
% hyp_mod = [flipdim([x y],1); x -y];

if debug
    h(k) = plot(hyp_mod(:,1),hyp_mod(:,2),'-b');
    k=k+1;
end

% rotate back to original points
hyp = hyp_mod*Rz(anglemid)';
if debug
    h(k) = plot(hyp(:,1),hyp(:,2),'-r');
    k=k+1;
end

% add arrow
arrow_pt1 = hyp(end-p.Results.arrowlength+1,:);
arrow_pt2 = hyp(end,:);
arrow_pts = [arrow_pt1; arrow_pt2];
arrow_length = sqrt(sum(diff(arrow_pts,1).^2));
arrow_width = arrow_length*0.25;

arrow_perp = [-arrow_pt1(2) arrow_pt1(1)];
u = arrow_perp/norm(arrow_perp);

% coeffs = polyfit(arrow_pts(:,1), arrow_pts(:,2), 1);
% m = -1/coeffs(1); % orthogonal slope
%b = arrow_pt1(1,2) - arrow_pt1(1,1)*m; % b = y - mx
%u = arrow_pt1*m;
%u = u/norm(u);
arrow_pts_new = zeros(4,2);
arrow_pts_new(1,:) = arrow_pt1 + arrow_width/2*u;
arrow_pts_new(2,:) = arrow_pt2;
arrow_pts_new(3,:) = arrow_pt1 - arrow_width/2*u;
arrow_pts_new(4,:) = arrow_pt2;

hyp = [hyp; arrow_pts_new];

if debug
    delete(h)
end

end

function add_labels(labels,coord,layout,type,offset)

nlabels = length(labels);

% set up point labels
for j=1:nlabels
    % NOTE if offset != 0 then you'll need an if statement to check if z ==
    % 0
    if coord(j,1) > 0
        % right side
        alignment = 'left';
    else
        % left side
        alignment = 'right';
    end

    r = norm(coord(j,:));
    multiple = (r+offset)/r;
    coord_new = multiple*coord(j,:);
    h = text(coord_new(1),coord_new(2),coord_new(3),labels{j},...
        'HorizontalAlignment',alignment);
    
    set(h,'FontSize',12,'FontName','Arial');
    
    switch layout
        case 'circle'
            angle = atan2(coord(j,2),coord(j,1));
            angledeg = angle*(180/pi);
            if isequal(alignment,'right')
                angledeg = angledeg + 180;
            end
            set(h,'Rotation',angledeg);
            
    end
end

end

function add_regions(obj,info,coord,layout,coord_order,width)

switch layout
    case 'circle'
        max_regions = max(info.region_order);
        nlabels = length(info.label);
        
        hregion = zeros(max_regions,1);
        region_str = cell(max_regions,1);
        
        % set up colors
        colors = obj.get_region_cmap('jet');
            
        pointsperlabel = 5;
        rad_inc = 2*pi/nlabels;
        % get the sorted idx
        idx = coord_order(1);
        for j=1:nlabels
            % find the region boundary
            % get the next sorted idx
            if j==nlabels
                idx2 = coord_order(1);
            else
                idx2 = coord_order(j+1);
            end
            if j~=nlabels
                if info.region_order(idx2) == info.region_order(idx)
                    continue;
                end
            end
            
            % get start and ending angles
            angle_start = atan2(coord(idx,2),coord(idx,1));
            angle_end = atan2(coord(idx2,2),coord(idx2,1));
            if angle_end > angle_start
                angle_end = -2*pi + angle_end;
            end
            
            % select points along arc
            angle_diff = angle_end - angle_start;
            npoints = ceil(abs(angle_diff/rad_inc))*pointsperlabel;
            angle = linspace(angle_start+rad_inc/2,angle_end+rad_inc/2,npoints);
            rinside = 1;    
            routside = rinside+width;
            x1 = rinside*cos(angle);
            y1 = rinside*sin(angle);
            angle_flip = flipdim(angle,2);
            x2 = routside*cos(angle_flip);
            y2 = routside*sin(angle_flip);
            
            x = [x1 x2];%x1(1)];
            y = [y1 y2];%y1(1)];
            
            % plot patch
            h = patch(x,y,colors(idx,:));
            % save handles to the legend
            if hregion(info.region_order(idx)) == 0
                hregion(info.region_order(idx)) = h;
                region_str{info.region_order(idx)} = info.region{idx};
            end
            
            idx = idx2;
        end
        
        idx_empty = isempty(hregion);
        hregion(idx_empty) = [];
        region_str(idx_empty) = [];
        l = legend(hregion,region_str,...
            'Location','SouthOutside',...
            'Orientation','Horizontal');
        legend('boxoff');
        
        set(l,'FontSize',12,'FontName','Arial');
end

end