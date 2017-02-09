function plot_single_multiple(obj,chj,chi,varargin)   
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

obj.save_tag = [];
p = inputParser();
addRequired(p,'chj',@isnumeric);
addRequired(p,'chi',@isnumeric);
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
parse(p,chj,chi,varargin{:});

chj = p.Results.chj;
chi = p.Results.chi;

if length(chj) ~= length(chi)
    error('chj and chi need to be same length');
end

for j=1:length(chj)
    obj.plot_single(chj(j),chi(j));
    
    % save
    obj.save_plot('save',p.Results.save,'outdir',p.Results.outdir);
end
end