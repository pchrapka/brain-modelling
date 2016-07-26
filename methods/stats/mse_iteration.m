function [data_mse] = mse_iteration(estimate,truth,varargin)
%MSE_ITERATION MSE vs iterations
%   MSE_ITERATION(estimate,truth,[params])
%
%   Input
%   -----
%   estimate (matrix/cell)
%       estimated values, size [iteration ...]
%
%       multiple simulations can also be included as a cell array, with
%       each cell containing the estimated values for one simulation
%
%   truth (matrix)
%       true values, size [iteration ...]
%
%   Parameters
%   ----------
%   normalized (boolean, default = false)
%       selects normalized or unnormalized MSE
%
%   Output
%   ------
%   data_mse (vector/matrix)
%       mse of estimates, matrix is returned when multiple simulations are
%       provided [iteration simulations]

% parse options
p = inputParser;
addRequired(p,'estimate');
addRequired(p,'truth');
addParameter(p,'normalized',false,@islogical);
parse(p,estimate,truth,varargin{:});

if iscell(p.Results.estimate)
    nsims = length(p.Results.estimate);
    niter = size(p.Results.estimate{1},1);
    nvars = numel(p.Results.estimate{1})/niter;
else
    nsims = 1;
    niter = size(p.Results.estimate,1);
    nvars = numel(p.Results.estimate)/niter;
end

data_mse = zeros(niter,nsims);
if ~iscell(p.Results.estimate)
    estimate = reshape(p.Results.estimate,niter,nvars);
    truth = reshape(p.Results.truth,niter,nvars);
    if p.Results.normalized
        data_mse(:,1) = nmse(estimate,truth,2);
    else
        data_mse(:,1) = mse(estimate,truth,2);
    end
else
    for j=1:nsims
        estimate = reshape(p.Results.estimate{j},niter,nvars);
        truth = reshape(p.Results.truth{j},niter,nvars);
        if p.Results.normalized
            data_mse(:,j) =  nmse(estimate,truth,2);
        else
            data_mse(:,j) = mse(estimate,truth,2);
        end
    end
end

end