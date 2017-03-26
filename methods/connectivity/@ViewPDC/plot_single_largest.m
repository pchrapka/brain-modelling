function plot_single_largest(obj,varargin)
%   Parameters
%   ----------
%   outdir (string)
%       output directory
%       by default uses output directory set in ViewPDC.outdir, can be
%       overriden here with:
%       1. 'data' - same directory where data is located
%       2. any regular path
%   save (logical, default = false)
%       flag to save figure

p = inputParser();
addParameter(p,'nplots',5,@isnumeric);
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
parse(p,varargin{:});

obj.save_tag = [];
obj.load('pdc');
obj.check_info();

% summarize data
% load data in pdc_get_summary to save summary file
out = pdc_get_summary(obj.pdc,...
    'file',obj.file,'w',obj.w,'fs',obj.fs);

% plot single and save each
for j=1:p.Results.nplots
    idxj_cur = out.idxj(out.idx_sorted(j));
    idxi_cur = out.idxi(out.idx_sorted(j));
    
    obj.plot_single(idxj_cur, idxi_cur);
    obj.save_tag = sprintf('-single-largest%d',j);
    
    % save
    obj.save_plot('save',p.Results.save,'outdir',p.Results.outdir);
end

end