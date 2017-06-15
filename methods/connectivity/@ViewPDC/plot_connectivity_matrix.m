function plot_connectivity_matrix(obj,varargin)
%   Parameters
%   ----------
%   outdir (string)
%       output directory for summary data
%       by default uses output directory set in ViewPDC.outdir, can be
%       overriden here with:
%       1. 'data' - same directory where data is located
%       2. any regular path
%   save (logical, default = false)
%       flag to save summary to data file

p = inputParser();
% addParameter(p,'save',false,@islogical);
% addParameter(p,'outdir','',@ischar);
addParameter(p,'samples','all',@(x) isequal(x,'all') || isvector(x));
parse(p,varargin{:});

obj.save_tag = [];
obj.load('pdc');
obj.check_info();

font_size = 14;

[nsamples,nchannels,~,nfreqs] = size(obj.pdc);

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

figure;
% threshold = 0.2;
conn_mat = obj.pdc(sample_idx,:,:,freq_idx);
% conn_mat1(conn_mat1 < threshold) = 0;
conn_mat = sum(conn_mat,4);
conn_mat = squeeze(mean(conn_mat,1));
for i=1:nchannels
    conn_mat(i,i) = 0;
end

% plot
imagesc(conn_mat);
colorbar();

% set labels
xticklabel = labels;
yticklabel = labels;
xtick = 1:length(xticklabel);
ytick = 1:length(yticklabel);
set(gca,...
    'XTick', xtick,...
    'XTickLabel','',...
    ...'XTickLabel', xticklabel, ...
    'FontSize',font_size);
ax = axis;
xl = ax(1:2);
yl = ax(3:4);
t = text(xtick,yl(2)*ones(1,length(xtick)),xticklabel);
set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
      'Rotation',90,'FontSize',font_size);
  
% Get the Extent of each text object.  This loop is unavoidable.
ext = [];
%ext_norm = [];
for i = 1:length(t)
  ext(i,:) = get(t(i),'Extent');
  %set(t(i),'Units','normalized');
  %ext_norm(i,:) = get(t(i),'Extent');
  %set(t(i),'Units','data');
end

% Determine the lowest point.  The X-label will be
% placed so that the top is aligned with this point.
min_ylabel = max(ext(:,2));

x_mid = xl(1)+abs(diff(xl))/2;
t_xlabel = text(x_mid,min_ylabel,'From', ...
    'VerticalAlignment','top', ...
    'HorizontalAlignment','center',...
    'FontSize',font_size);

set(t_xlabel,'Units','normalized');
ext_xlabel = get(t_xlabel,'Extent');

% outpos = get(gca,'OuterPosition');
% outpos(2) = outpos(2) - ext_xlabel(2);
% outpos(4) = outpos(4) - abs(ext_xlabel(2));
% set(gca,'OuterPosition',outpos);
outpos = get(gca,'Position');
outpos(2) = outpos(2) - ext_xlabel(2)/2;
outpos(4) = outpos(4) - abs(ext_xlabel(2))/2;
set(gca,'Position',outpos);

% xlabel('From');
set(gca,...
    'YTick', ytick,...
    'YTickLabel', yticklabel, ...
    'FontSize',font_size);
ylabel('To');

obj.save_tag = sprintf('-adjacency-idx%d-%d',min(sample_idx),max(sample_idx));

end