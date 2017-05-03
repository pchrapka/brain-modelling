function plot_mse_vs_sparsity(data_series,sparsity,varargin)
%PLOT_MSE_VS_SPARSITY plot average MSE vs sparsity
%   PLOT_MSE_VS_SPARSITY(data_series, sparsity, ...) plots average MSE vs
%   sparsity. It also averages over multiple simulations for smoother
%   results.
%
%   Input
%   -----
%   data_series (struct array)
%       contains a struct for each data series, as an example each series
%       can correspond to a different filter type
%       the struct contains the following fields
%
%       estimate (cell array of cells)
%           each entry corresponds to a specific sparsity value, each entry
%           can also contains results from multiple simulations
%       truth (cell array of cells)
%           each entry corresponds to a specific sparsity value, each entry
%           can also contains results from multiple simulations
%
%       the entry order in estimate and truth should correspond with each
%       other
%
%   sparsity (array)
%       sparsity values corresponding to each entry in estimate and truth
%
%   Parameters
%   ----------
%   mode (string, default = 'plot')
%       plotting mode
%       'plot' - plots data with plot function
%       'log' - plots data with semilogy function
%   samples (2-element vector, default = [1 nsamples])
%       sample indices over which to average the MSE, beneficial to select
%       samples where the filter has converged
%   labels (cell array)
%       labels for legend
%   normalized (boolean, default = false)
%       selects normalized or unnormalized MSE

p = inputParser;
addRequired(p,'data_series',@isstruct);
addRequired(p,'sparsity',@isnumeric);
addParameter(p,'labels',{},@iscell);
addParameter(p,'samples',[],@(x) isnumeric(x) && (length(x) == 2));
addParameter(p,'normalized',false,@islogical);
params_mode = {'plot','log'};
addParameter(p,'mode','plot',@(x)any(validatestring(x,params_mode)));
parse(p,data_series,sparsity,varargin{:});

nseries = length(data_series);
nsparsity = length(p.Results.sparsity);
for i=1:nseries
    if ~isfield(data_series(i),'estimate')
        error([mfilename ':input'],'missing estimate field for series %d',i);
    end
    if ~isfield(data_series(i),'truth')
        error([mfilename ':input'],'missing truth field for series %d',i);
    end
    
    if nsparsity ~= length(data_series(i).estimate)
        error([mfilename ':input'],'missing sparsity axis or data in series %d estimate',i);
    end
    
    if nsparsity ~= length(data_series(i).truth)
        error([mfilename ':input'],'missing sparsity axis or data in series %d truth',i);
    end
end

nsims = length(data_series(i).estimate{1});

nplots = nseries;
if nplots <= 4
    cc = [0 0 0;% black
        0 0 1; % blue
        0 1 0; % green
        1 0 1; % magenta
        ];
else
    cc = jet(nplots);
end
markers_default = {'o','x','+','*','s','d','v','^','<','>','p','h'};
markers = repmat(markers_default,1,ceil(nplots/length(markers_default)));
line_types_default = {'-',':','-.','--'};
line_types = repmat(line_types_default,1,ceil(nplots/4));

h = [];
for i=1:nseries
    data_plot = zeros(nsparsity,1);
    for j=1:nsparsity
        data_mse = mse_iteration(...
            data_series(i).estimate{j},...
            data_series(i).truth{j},...
            'normalized',p.Results.normalized);
        if nsims > 1
            % average over sims
            data_mse = mean(data_mse,2);
        end
        
        samples = p.Results.samples;
        if isempty(samples)
            samples = [1 size(data_mse,1)];
        end
        % average over iterations
        data_plot(j) = mean(data_mse(samples(1):samples(2)),1);
    end
    
    switch p.Results.mode
        case 'log'
            h(i) = semilogy(p.Results.sparsity(:),data_plot,...
                [line_types{i} markers{i}],'Color',cc(i,:),'LineWidth',2);
        case 'plot'
            h(i) = plot(p.Results.sparsity(:),data_plot,...
                [line_types{i} markers{i}],'Color',cc(i,:),'LineWidth',2);
    end
    hold on;
end

if p.Results.normalized
    ylabel('NMSE');
else
    ylabel('MSE');
end
xlabel('Sparsity');

if ~isempty(p.Results.labels)
    legend(h,p.Results.labels);%,'Location','BestOutside');
end

end