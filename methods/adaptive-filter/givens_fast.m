function [ X, D, M ] = givens_fast(i, k, X, D)
%GIVENS_FAST Fast Givens rotation coefficients
%
%   Input
%   -----
%   i
%       row
%   k
%       column
%   X
%       data matrix
%   D
%       diagonal of diagonal matrix 
%       on first rotation 
%           D = []
%       on subsequent rotation
%           D = D from previous call
%
%   Output
%   ------
%   X
%       rotated matrix, where element at (i,k) is zeroed
%       X = F'*Xprev, where F is the fast Givens transformation
%   D
%       updated diagonal matrix, 
%       diag(D) = F'diag(Dprev)F
%   M
%       2x2 fast Givens transformation for rows i and k
%
% NOTE Lewis uses the 1983 Golub van Loan and his notation differs

if isempty(D)
    D = ones(size(X,1),1);
end

% extract elements
%row_idx = sort([i k]);
row_idx = [i k];
x = X(row_idx,k);
d = D(row_idx,1);

% compute transform
[M, d] = givens_fast_transform(x,d);

% apply fast givens transformation
X(row_idx,:) = M'*X(row_idx,:);
% update diagonal
D(row_idx,1) = d;

end