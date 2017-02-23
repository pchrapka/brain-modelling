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
addParameter(p,'file_idx',[],@isvector);
parse(p,varargin{:});

% TODO how to specify file_idx
if length(obj.datafiles) > 1 && isempty(p.Results.file_idx)
    error('please specify file idx');
else
    file_idx = 1;
end

if length(file_idx) > 1
    error('modify function to reflect multiple files');
end

% load data
obj.load('criteria',file_idx);
criteria = p.Results.criteria;

% get data
order_list = obj.criteria.(criteria).order_list;

if length(file_idx) == 1
    [~,name,~] = fileparts(obj.datafiles{file_idx});
    name = strrep(name,'-',' ');
    name = strrep(name,'_','-');
else
    name = 'TODO fix me';
end

figure('Position',[1 1 1000 600],'Name',name);

subplot(2,1,1);
plot(order_list,obj.criteria.(criteria).f,'-o');
xlabel('Model order');
ylabel('IC');
title(sprintf('Forward IC - %s',upper(p.Results.criteria)));

subplot(2,1,2);
plot(order_list,obj.criteria.(criteria).b,'-o');
xlabel('Model order');
ylabel('IC');
title(sprintf('Backward IC - %s',upper(p.Results.criteria)));

end