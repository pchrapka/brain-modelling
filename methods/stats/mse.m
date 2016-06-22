function [error] = mse(estimate, target, varargin)
%MSE calculates the mean square error between true and estimated values
%   MSE(estimate, target, [dim]) calculates the mean square error between the
%   estimate and target
%
%   Input
%   -----
%   estimate (matrix)
%       estimated value
%   target (matrix)
%       target value
%   dim (integer, optional)
%       takes mse along dimension DIM, default = 1
%
%   Output
%   ------
%   error (matrix)
%       MSE of estimates

if nargin > 2
    dim = varargin{1};
else
    dim = 1;
end

% zero nans
estimate(isnan(estimate)) = 0;
target(isnan(target)) = 0;

error = mean((estimate - target).^2,dim);

end