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

obj.save_tag = [];
obj.load();
obj.check_info();

[~,nchannels,~,~] = size(obj.pdc);

data_summary = obj.get_summary('save',p.Results.save,'outdir',p.Results.outdir);

title('PDC - Channel Pair Summary');
imagesc(data_summary.mag_matrix);
colorbar();
xlabel('Channels');
ylabel('Channels');

ticks = 1:nchannels;
set(gca,...
    'Xtick',ticks,...
    'XtickLabel',obj.info.label,...
    'Ytick',ticks,...
    'YtickLabel',obj.info.label);

obj.save_tag = '-summary';

end