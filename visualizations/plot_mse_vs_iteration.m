function plot_mse_vs_iteration(varargin)
%PLOT_MSE_VS_ITERATION plot MSE vs iteration
%   PLOT_MSE_VS_ITERATION(estimate1,truth1 [,estimate2,truth2,...])
%
%   Input
%   -----
%   estimate (matrix)
%       estimated values, size [iteration variables]
%   truth (matrix)
%       true values, size [iteration variables]
%
%   Parameters
%   ----------

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
params_mode = {'plot','log'};
addParameter(p,'mode','plot',@(x)any(validatestring(x,params_mode)));
parse(p,varargin{ndata:end});

ndata = ndata-1;
niter = size(data{1},1);
nvars = numel(data{1})/niter;
for i=1:2:ndata
    estimate = reshape(data{i},niter,nvars);
    truth = reshape(data{i+1},niter,nvars);
    data_mse = mse(estimate,truth,2);
    switch p.Results.mode
        case 'log'
            semilogy(1:niter,data_mse);
        case 'plot'
            plot(1:niter,data_mse);
    end
    hold on;
end
ylabel('MSE');
xlabel('Iteration');

if ~isempty(p.Results.labels)
    legend(p.Results.labels);
end

end