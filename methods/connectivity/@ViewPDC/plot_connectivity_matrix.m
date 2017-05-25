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
    'XTickLabel', xticklabel, ...
    'FontSize',12);
xlabel('From');
set(gca,...
    'YTick', ytick,...
    'YTickLabel', yticklabel, ...
    'FontSize',12);
ylabel('To');

obj.save_tag = sprintf('-adjacency-idx%d-%d',min(sample_idx),max(sample_idx));

end