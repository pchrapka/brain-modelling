function plot_connectivity_matrix(obj,varargin)
%   Parameters
%   ----------
%   samples (vector, default = all)
%       sample index to use

p = inputParser();
addParameter(p,'samples','all',@(x) isequal(x,'all') || isvector(x));
parse(p,varargin{:});

debug = false;

obj.save_tag = [];
obj.load('pdc');
obj.check_info();

font_size = 14;

[nsamples,nchannels,~,~] = size(obj.pdc);
nfreqs = obj.pdc_nfreqs;

if isequal(p.Results.samples,'all')
    sample_idx = 1:nsamples;
else
    sample_idx = p.Results.samples;
end

w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

labels = obj.info.label;

% coord = zeros(nchannels,2);
% for i=1:nchannels
%     coord(i,:) = [cos(2*pi*(i - 1)./nchannels), sin(2*pi*(i - 1)./nchannels)];
% end

figure('Position',[200 200 800 700]);
% threshold = 0.2;
conn_mat = obj.pdc(sample_idx,:,:,freq_idx);
dims = size(conn_mat);
% conn_mat1(conn_mat1 < threshold) = 0;
conn_mat = sum(conn_mat,4); % sum over freqs
conn_mat = squeeze(sum(conn_mat,1)); % sum over samples
conn_mat = conn_mat/(dims(1)*dims(4)); % take average
for i=1:nchannels
    conn_mat(i,i) = 0;
end

% sort by hemisphere, region, angle
idx_sort = obj.sort_channels('type',{'region'});
idx_sort = idx_sort(:);
conn_mat = conn_mat(idx_sort,idx_sort);

% plot
colormap('jet');
imagesc(conn_mat);
colorbar();
axis square;

% set labels
xticklabel = labels(idx_sort);
yticklabel = labels(idx_sort);
xtick = 1:length(xticklabel);
ytick = 1:length(yticklabel);
% xlabel('From');
set(gca,...
    'YTick', ytick,...
    'YTickLabel', yticklabel, ...
    'FontSize',font_size);
ylabel('To');

set(gca,...
    'XTick', xtick,...
    'XTickLabel','',...
    ...'XTickLabel', xticklabel, ...
    'FontSize',font_size);
ax = axis;
xl = ax(1:2);
yl = ax(3:4);
t = text(xtick,yl(2)*ones(1,length(xtick)),xticklabel);
set(t,'HorizontalAlignment','right','VerticalAlignment','middle', ...
      'Rotation',90,'FontSize',font_size);
  
% Get the Extent of each text object.  This loop is unavoidable.
ext = [];
%ext_norm = [];
for i = 1:length(t)
    set(t(i),'Units','normalized');
    ext(i,:) = get(t(i),'Extent');
end

max_ylabel = max(ext(:,4));

outpos = get(gca,'Position');
% outpos_orig = outpos;
outpos(2) = outpos(2) + max_ylabel;
% margin = 1 - outpos(4);
% outpos(4) = 1 - margin - max_ylabel; %outpos(4) - max_ylabel/2;
outpos(4) = outpos(4) - max_ylabel; %outpos(4) - max_ylabel/2;
set(gca,'Position',outpos);

% Get the Extent of each text object.  This loop is unavoidable.
ext = [];
%ext_norm = [];
for i = 1:length(t)
    set(t(i),'Units','data');
    ext(i,:) = get(t(i),'Extent');
    if debug
        xp = [ext(i,1) ext(i,1)+ext(i,3) ext(i,1)+ext(i,3) ext(i,1)];
        yp = [ext(i,2) ext(i,2)          ext(i,2)-ext(i,4) ext(i,2)-ext(i,4)];
        rect = line(xp,yp);
        set(rect,'clipping','off');
    end
end

% Determine the lowest point.  The X-label will be
% placed so that the top is aligned with this point.
min_ylabel = max(ext(:,2));

x_mid = xl(1)+abs(diff(xl))/2;
t_xlabel = text(x_mid,min_ylabel,'From', ...
    'VerticalAlignment','top', ...
    'HorizontalAlignment','center',...
    ...'Units','normalized',...
    'FontSize',font_size);

drawnow;

obj.save_tag = sprintf('-adjacency-idx%d-%d',min(sample_idx),max(sample_idx));

end