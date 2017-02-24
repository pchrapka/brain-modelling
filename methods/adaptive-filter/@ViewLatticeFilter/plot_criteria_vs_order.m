function plot_criteria_vs_order(obj,varargin)
%PLOT_CRITERIA_VS_ORDER plots filter order vs information criteria
%   PLOT_ESTERROR_VS_ORDER(...) plots filter order vs information criteria
%
%   Parameters
%   -----
%   criteria (string, default = 'aic')
%       criteria to plot
%   orders (vector)
%       list of orders to use in plot
%   file_idx (vector, default = 1)
%       indices of files whose data should be plotted

p = inputParser();
addParameter(p,'criteria','aic',...
    @(x) any(validatestring(x,{'aic','sc','norm'})));
addParameter(p,'orders',[],@isvector);
addParameter(p,'file_list',[],@isvector);
parse(p,varargin{:});

params = struct2namevalue(p.Results);
data_crit = obj.get_criteria(params{:});

ndata = length(data_crit.legend_str);
nfiles = length(data_crit.f);
nsamples = size(data_crit.f{1},2);

% create figure name
[~,name,~] = fileparts(obj.datafiles{1});
name = strrep(name,'-',' ');
name = strrep(name,'_','-');
if nfiles > 1
    out = sprintf('%s-', obj.datafile_labels{:});
    name = [name '-' out(1:end-1)];
end

figure('Position',[1 1 1000 600],'Name',name);

markers = {'o','x','+','*','s','d','v','^','<','>','p','h'};
linetypes = {'-',':','-.','--'};

subplot(2,1,1);
hold on;
% plot last IC vs order
h = zeros(nfiles,1);
for file_idx=1:nfiles
    h(file_idx) = plot(data_crit.order_lists{file_idx},data_crit.f{file_idx},...
        ['-' markers{file_idx}]);
end
if nfiles > 1
    legend(h,obj.datafile_labels);
end
xlabel('Model order');
ylabel('IC');
title(sprintf('Forward IC - %s',upper(p.Results.criteria)));

subplot(2,1,2);
hold on;
h = zeros(nfiles,1);
for file_idx=1:nfiles
    h(file_idx) = plot(data_crit.order_lists{file_idx},data_crit.b{file_idx},...
        ['-' markers{file_idx}]);
end
xlabel('Model order');
ylabel('IC');
title(sprintf('Backward IC - %s',upper(p.Results.criteria)));

end