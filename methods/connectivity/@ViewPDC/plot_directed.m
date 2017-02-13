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
parse(p,varargin{:});

obj.load();

[nsamples,nchannels,~,nfreqs] = size(obj.pdc);

w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

if isempty(obj.labels)
    labels = cell(nchannels,1);
else
    labels = obj.labels;
end

coord = zeros(nchannels,2);
for i=1:nchannels
    coord(i,:) = [cos(2*pi*(i - 1)./nchannels), sin(2*pi*(i - 1)./nchannels)];
    if isempty(labels{i})
        labels{i} = sprintf('%d',i);
    end
end

% set up avi file
if p.Results.makemovie
    obj.save_tag = '-adjacency';
    outdir = obj.get_outdir(p.Results.outdir);
    outfile = fullfile(outdir,[obj.get_savefile() '.avi']);
    
    vidobj = VideoWriter(outfile,'Motion JPEG AVI');
    open(vidobj);
end

figure('Position',[100 100, 1000, 600]);
axis off;
q = [];

% set up colormap
value_max = length(freq_idx);
cmap = colormap(hot);
cmap = flipdim(cmap,1);
colormap(cmap);
ncolors = size(cmap,1);

% format
hold on;
ylim([-1.1 1.1]);
xlim([-1.1 1.1]);
for j=1:nchannels
    offset = 1/20;
    text(coord(j,1)+offset,coord(j,2)+offset,labels{j});
end
colorbar('Location','EastOutside');

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
                scaling = 0;
                q(qcount) = quiver(coord(j,1),coord(j,2),dx,dy,scaling,...
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