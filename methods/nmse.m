function [error] = nmse(estimate, target, varargin)
%NMSE calculates the normalized mean square error between true and estimated values
%   NMSE(estimate, target, [dim]) calculates the normalized mean square
%   error between the estimate and target
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
%       NMSE of estimates

if nargin > 2
    dim = varargin{1};
else
    dim = 1;
end

% zero nans
estimate(isnan(estimate)) = 0;
target(isnan(target)) = 0;

error = mean((estimate - target).^2,dim)./mean(target.^2,dim);

end