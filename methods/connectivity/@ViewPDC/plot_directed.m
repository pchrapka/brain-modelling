function plot_directed(obj,varargin)
%   Parameters
%   ----------
%   makemovie (logical, default = false)
%       flag to make and save movie
%   threshold (numeric, default = 0)
%       threshold for PDC, connections below this threshold are not plotted
%   pausetime (numeric, default = 0.01)
%       time to pause for each frame, relevant if makemovie = false
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
addParameter(p,'layout','default',@(x) any(validatestring(x,{'default','openhemis'})));
parse(p,varargin{:});

obj.save_tag = [];
obj.load();

[nsamples,nchannels,~,nfreqs] = size(obj.pdc);

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

% set up coords
if isempty(obj.coords)
    coord = zeros(nchannels,3);
    for i=1:nchannels
        coord(i,:) = [cos(2*pi*(i - 1)./nchannels), sin(2*pi*(i - 1)./nchannels) 0];
    end
else
    coord = obj.coords;
end

% open up coordinate layout
switch p.Results.layout
    case 'default'
    case 'openhemis'
        % open hemispheres
        
        % shift front to (0,0,offset)
        [~,idx_front] = min(coord(:,3));
        [~,idx_back] = max(coord(:,3));
        brain_length = coord(idx_front,3) - coord(idx_back,3);
        %offset = 0.2*brain_length;
        
        %coord_temp = coord - repmat([
        
        idx_right = coord(:,1) > 0;
        idx_left = ~idx_right;
        angle = pi/4;
        Rz_ccw = rotZ(angle); % counter clockwise for left
        Rz_cw = rotZ(-angle); % clockwise for right
        
        % rotate the coordinates
        coord_temp(idx_right,:) = coord(idx_right,:)*Rz_cw';
        coord_temp(idx_left,:) = coord(idx_left,:)*Rz_ccw';
        
        % separate the coordinates
        offset = sqrt(2)*brain_length/2;
        nright = sum(idx_right);
        nleft = sum(idx_left);
        coord_temp(idx_right,1) = coord_temp(idx_right,1) + repmat(offset,nright,1);
        coord_temp(idx_left,1) = coord_temp(idx_left,1) + repmat(-offset,nleft,1);
        
        coord = coord_temp;
end

% set up avi file
if p.Results.makemovie
    obj.save_tag = '-adjacency';
    outdir = obj.get_outdir(p.Results.outdir);
    outfile = fullfile(outdir,[obj.get_savefile() '.avi']);
    
    vidobj = VideoWriter(outfile,'Motion JPEG AVI');
    open(vidobj);
end

% set up full screen figure
%figure('Position', get(0,'screensize'));
figure('Position', [100 100 1000 600]);

% format
hold on;
axis off;

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
    text(coord(j,1)+offset,coord(j,2)+offset,coord(j,3)+offset,labels{j});
end

q = [];
for s=1:nsamples
    % clear q's
    if ~isempty(q)
        delete(q);
    end
    
    adj_mat1 = squeeze(obj.pdc(s,:,:,freq_idx)); 
    adj_mat1(adj_mat1 < p.Results.threshold) = 0;
    adj_mat = sum(adj_mat1,3);
    %disp(adj_mat);
    
    % plot
    % from j to i
    qcount = 1;
    q = [];
    for j=1:nchannels
        for i=1:nchannels
            if i == j
                % skip the diagonal
                continue;
            end
            
            if adj_mat(j,i) > 0
                pct = adj_mat(j,i)/value_max;
                color_idx = ceil(ncolors*pct);
                
                dx = coord(i,1) - coord(j,1);
                dy = coord(i,2) - coord(j,2);
                dz = coord(i,3) - coord(j,3);
                
                scaling = 0;
                
                q(qcount) = quiver3(...
                    coord(j,1),coord(j,2),coord(j,3),...
                    dx,dy,dz,scaling,...
                    'Color',cmap(color_idx,:));
                qcount = qcount + 1;
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