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

% set up labels
if isempty(obj.info)
    labels = cell(nchannels,1);
    for i=1:nchannels
        labels{i} = sprintf('%d',i);
    end
else
    labels = obj.info.label;
end

% set up coordinate layout
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
            
            % sort by angle,region,hemisphere
            % sort coordinates according to angle around origin
            angles = atan2(obj.info.coord(:,2),obj.info.coord(:,1));
            
            sort_method = 1;
            group_data = angles(:);
            
            if ~isempty(obj.info.region_order)
                % add region order sort info
                group_data = [group_data obj.info.region_order(:)];
                ncol = size(group_data,2);
                sort_method = [ncol sort_method];
            end
            
            if ~isempty(obj.info.hemisphere_order)
                % add hemisphere order sort info
                group_data = [group_data obj.info.hemisphere_order(:)];
                ncol = size(group_data,2);
                sort_method = [ncol sort_method];
            end
            
            [~,idx] = sortrows(group_data,sort_method);
            
            if ~isempty(obj.info.hemisphere)
                % flip left side so that front is at the top
                idx_left = cellfun(@(x) ~isempty(x),...
                    strfind(obj.info.hemisphere(idx),'Left'),'UniformOutput',true);
                idx_left_sorted = idx(idx_left);
                idx_left_sorted = flipdim(idx_left_sorted,1);
                idx(idx_left) = idx_left_sorted;
            end
                
            
            % set up equally space coordinates for plot 
            % based on ordered idx
            for i=1:nchannels
                angle = -2*pi*(i - 1)./nchannels + pi/2;
                coord(idx(i),:) = [cos(angle), sin(angle), 0];
            end
            
        end
        
        axislim_multiple = 1.4;
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

% add labels
add_labels(labels,coord,p.Results.layout,type);

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
        title(sprintf('sample: %d',s));
    else
        title(sprintf('time: %0.0fms',obj.time(s)*1000));
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

% reshape points
pt1 = reshape(pt1,1,2);
pt2 = reshape(pt2,1,2);
origin = [0 0];
pts = [pt1; pt2; origin];

% plot(pts(:,1),pts(:,2),'ro','LineWidth',2);

% rotate so that mid angle is along the x axis
angle1 = atan2(pt1(2),pt1(1));
angle2 = atan2(pt2(2),pt2(1));
anglediff = angle2-angle1;
anglemid = anglediff/2 + angle1;
Rz = @(angle) [cos(angle) -sin(angle); sin(angle) cos(angle)];
pts_mod = pts*Rz(-anglemid)';

% hold on;
% plot(pts_mod(:,1),pts_mod(:,2),'bo','LineWidth',2);

% a is free to specify
if abs(anglediff) >= pi/2 && abs(anglediff) <= 3*pi/2
    % let longer arcs pass closer to center
    a = 0.2;
else
    a = p.Results.a;
end
% fit b to points
b = sqrt(a^2*pts_mod(1,2)^2/(pts_mod(1,1)^2- a^2));

% compute hyperbola
y = linspace(0,pts_mod(1,2))';
x = sqrt(a^2*(1+y.^2/b^2));
hyp_mod = [flipdim([x y],1); x -y];
%plot(hyp_mod(:,1),hyp_mod(:,2),'-b');

% rotate back to original points
hyp = hyp_mod*Rz(anglemid)';
% plot(hyp(:,1),hyp(:,2),'-r');

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

end

function add_labels(labels,coord,layout,type)

nlabels = length(labels);

% set up point labels
for j=1:nlabels
    %offset = 1/20;
    offset = 0;
    % NOTE if offset != 0 then you'll need an if statement to check if z ==
    % 0
    if coord(j,1) > 0
        % right side
        alignment = 'left';
    else
        % left side
        alignment = 'right';
    end
    h = text(coord(j,1)+offset,coord(j,2)+offset,coord(j,3)+offset,labels{j},...
        'HorizontalAlignment',alignment);
    
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