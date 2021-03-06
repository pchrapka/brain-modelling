function [ M, d, varargout ] = givens_fast_transform(x, d)
%GIVENS_FAST_TRANSFORM fast Givens transformation
%   [M, d, [alpha, beta, type]] = GIVENS_FAST_TRANSFORM(x,d) returns the
%   fast Givens transformation 
%
%   M'*x = [ r ]
%          [ 0 ]
%
%   M'DM = D1, where D1 is a diagonal matrix
%
%   For more details see: Golub and van Loan, p221 Algorithm 5.1.4
%
%   Input
%   -----
%   x
%       data
%   d
%       diagonal of diagonal matrix, d = diag(D)
%
%   Output
%   ------
%   M
%       2x2 Modified Fast Givens transformation
%   d
%       updated diagonal vector, d = diag(D1)
%   alpha (optional)
%       alpha coefficient
%   beta (optional)
%       beta coefficient
%   type (optional)
%       transformation type
%
%   Golub and van Loan, p221 Algorithm 5.1.4

if x(2) ~= 0
    alpha = -x(1)/x(2);
    beta = -alpha*d(2)/d(1);
    gamma = -alpha*beta;
    if gamma <= 1
        type = 1;
        t = d(1);
        d(1) = (1+gamma)*d(2);
        d(2) = (1+gamma)*t;
    else
        type = 2;
        alpha = 1/alpha;
        beta = 1/beta;
        gamma = 1/gamma;
        d(1) = (1+gamma)*d(1);
        d(2) = (1+gamma)*d(2);
    end
else
    type = 2;
    alpha = 0;
    beta = 0;
end

if type==1
    M = [beta 1; 1 alpha];
else
    M = [1 alpha; beta 1];
end

nout = max(nargout,2)-2;
tempout = {alpha, beta, type};
varargout = tempout(1:nout);

end

