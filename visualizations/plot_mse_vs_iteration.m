function plot_mse_vs_iteration(varargin)
%PLOT_MSE_VS_ITERATION plot MSE vs iteration
%   PLOT_MSE_VS_ITERATION(estimate1,truth1 [,estimate2,truth2,...])
%
%   Input
%   -----
%   estimate (matrix/cell)
%       estimated values, size [iteration variables]
%
%       multiple simulations can also be included as a cell array, with
%       each cell containing the estimated values for one simulation
%
%   truth (matrix)
%       true values, size [iteration variables]
%
%   Parameters
%   ----------
%   mode (string, default = 'plot')
%       plotting mode
%       'plot' - plots data with plot function
%       'log' - plots data with semilogy function
%   labels (cell array)
%       labels for legend
%   normalized (boolean, default = false)
%       selects normalized or unnormalized MSE

% parse data inputs
ndata = 1;
while ndata <= nargin
    if ischar(varargin{ndata})
       break;
    else    
        ndata = ndata + 1;
    end
end
data = varargin(1:ndata-1);

% parse plot options
p = inputParser;
addParameter(p,'labels',{},@iscell);
addParameter(p,'normalized',false,@islogical);
params_mode = {'plot','log'};
addParameter(p,'mode','plot',@(x)any(validatestring(x,params_mode)));
parse(p,varargin{ndata:end});

ndata = ndata-1;
if iscell(data{1})
    nsims = length(data{1});
else
    nsims = 1;
end

for i=1:2:ndata
    data_mse = mse_iteration(data{i},data{i+1});
    if nsims > 1
        data_mse = mean(data_mse,2);
    end
    
    niter = size(data_mse,1);
    switch p.Results.mode
        case 'log'
            semilogy(1:niter,data_mse);
        case 'plot'
            plot(1:niter,data_mse);
    end
    hold on;
end

if p.Results.normalized
    ylabel('NMSE');
else
    ylabel('MSE');
end
xlabel('Iteration');

if ~isempty(p.Results.labels)
    legend(p.Results.labels);
end

end