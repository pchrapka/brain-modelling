function plot_summary(obj,varargin)
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

[~,nchannels,~,~] = size(obj.pdc);

data_summary = obj.get_summary('save',p.Results.save,'outdir',p.Results.outdir);

title('PDC - Channel Pair Summary');
imagesc(data_summary.mag_matrix);
colorbar();
xlabel('Channels');
ylabel('Channels');

ticks = 1:nchannels;
if isempty(obj.labels)
    tick_labels = cell(nchannels,1);
    for i=1:nchannels
        tick_labels{i} = num2str(i);
    end
    set(gca,...
        'Xtick',ticks,...
        'XtickLabel',tick_labels,...
        'Ytick',ticks,...
        'YtickLabel',tick_labels);
else
    set(gca,...
        'Xtick',ticks,...
        'XtickLabel',obj.labels,...
        'Ytick',ticks,...
        'YtickLabel',obj.labels);
end

obj.save_tag = '-summary';

end