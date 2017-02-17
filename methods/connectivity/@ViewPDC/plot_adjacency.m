function plot_adjacency(obj,varargin)
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

obj.save_tag = [];
p = inputParser();
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
parse(p,varargin{:});

obj.load();

[nsamples,nchannels,~,nfreqs] = size(obj.pdc);

w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

if isempty(obj.info)
    labels = cell(nchannels,1);
else
    labels = obj.info.label;
end

coord = zeros(nchannels,2);
for i=1:nchannels
    coord(i,:) = [cos(2*pi*(i - 1)./nchannels), sin(2*pi*(i - 1)./nchannels)];
    if isempty(labels{i})
        labels{i} = sprintf('%d',i);
    end
end

figure;
threshold = 0.2;
for i=1:nsamples
    adj_mat1 = squeeze(obj.pdc(i,:,:,freq_idx)); 
    adj_mat1(adj_mat1 < threshold) = 0;
    adj_mat = sum(adj_mat1,3);
    disp(adj_mat);
    
    % plot
    [x,y] = bct.adjacency_plot_und(adj_mat,coord);
    plot(x,y);
    
    % format
    ylim([-1 1]);
    xlim([-1 1]);
    for j=1:nchannels
        offset = 1/20;
        text(coord(j,1)+offset,coord(j,2)+offset,labels{j});
    end
end

obj.save_tag = '-adjacency';

end