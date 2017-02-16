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
if isempty(obj.labels)
    labels = cell(nchannels,1);
    for i=1:nchannels
        labels{i} = sprintf('%d',i);
    end
else
    labels = obj.labels;
end

% set up coordinate layout
switch p.Results.layout
    case 'default'
        coord = obj.coords;
    case 'circle'
        % ignore obj.coords
        coord = [];
        % set up circular
    case 'openhemis'
        % open hemispheres
        if isempty(obj.coords)
            error('no anatomical coordinates specified');
        end
        coord = obj.coords;
        
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
    coord = zeros(nchannels,3);
    for i=1:nchannels
        coord(i,:) = [cos(2*pi*(i - 1)./nchannels), sin(2*pi*(i - 1)./nchannels) 0];
    end
end

% set up avi file
if p.Results.makemovie
    obj.save_tag = sprintf('-adjacency-%s-thresh%0.2f',p.Results.layout,p.Results.threshold);
    outdir = obj.get_outdir(p.Results.outdir);
    outfile = fullfile(outdir,[obj.get_savefile() '.avi']);
    
    vidobj = VideoWriter(outfile,'Motion JPEG AVI');
    open(vidobj);
end

% set up full screen figure
if debug
    figure('Position', [100 100 1000 600]);
else
    figure('Position', get(0,'screensize'));
end

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
else
    type = '3d';
    view([0 45]);
end

% set up colormap
value_max = length(freq_idx);
cmap = colormap(hot);
cmap = flipdim(cmap,1);
colormap(cmap);
ncolors = size(cmap,1);
colorbar('Location','EastOutside');

% set x,y,z limits
multiple = 1.1;
lim_func = {'xlim','ylim','zlim'};
for i=1:3
    dimmin = min(coord(:,i));
    dimmax = max(coord(:,i));
    
    fh = str2func(lim_func{i});
    fh(multiple*[dimmin dimmax]);
end
    
% set up point labels
for j=1:nchannels
    %offset = 1/20;
    offset = 0;
    % NOTE if offset != 0 then you'll need an if statement to check if z ==
    % 0
    if coord(j,1) > 0
        alignment = 'left';
    else
        alignment = 'right';
    end
    text(coord(j,1)+offset,coord(j,2)+offset,coord(j,3)+offset,labels{j},...
        'HorizontalAlignment',alignment);
end
scatter3(coord(:,1),coord(:,2),coord(:,3),50,'filled','ob'); 

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
                    % new quiver
                    dx = coord(i,1) - coord(j,1);
                    dy = coord(i,2) - coord(j,2);
                    dz = coord(i,3) - coord(j,3);
                    
                    conns(j,i).q = quiver3(...
                        coord(j,1),coord(j,2),coord(j,3),...
                        dx,dy,dz,scaling,...
                        'Color',cmap(color_idx,:),...
                        'LineWidth',linewidth);
                else
                    % update quiver
                    % color and line width
                    set(conns(j,i).q,...
                        'Color',cmap(color_idx,:),...
                        'LineWidth',linewidth);
                end
            else
                % delete quiver
                if ~isempty(conns(j,i).q)
                    delete(conns(j,i).q);
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