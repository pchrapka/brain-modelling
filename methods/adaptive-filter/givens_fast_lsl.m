function [ X,d ] = givens_fast_lsl(X,d,m)
%GIVENS_FAST_LSL fast Givens transformation for least squares lattice
%   [X,d] = GIVENS_FAST_LSL(X,d,m) zeros the first m elements in the first
%   row of X using the fast Givens transformation
%
%   Example:
%   m = 4
%   X = [ x x x x x x x    M'    X = [ 0 0 0 0 x x x
%         x x x x x x x   --->         x x x x x x x
%         0 x x x x x x                0 x x x x x x
%         0 0 x x x x x                0 0 x x x x x
%         0 0 0 x x x x]               0 0 0 x x x x]
%   
%   
%   Input
%   -----
%   X
%       upper triangular matrix with a new 1st row
%   d
%       diagonal of diagonal matrix D, set to the identity if empty 
%   m
%       number of elements to zero in the first row
%
%   Output 
%   ------
%   X
%       upper triangular matrix with m zero elements in the first row
%   d
%       updated diagonal of diagonal matrix D
%
%   See also GIVENS_FAST_MOD_TRANSFORM

[rows,cols] = size(X);
if isempty(d)
    d = ones(rows,1);
end

% extract elements
%row_idx = sort([i k]);
for j=1:m
    %i=1;
    row_idx = [1 j+1];
    %row_idx = [1 2];
    x = X(row_idx,j);
    d1 = d(row_idx,1);
    
    % compute fast Givens transform
    [M, d1] = givens_fast_mod_transform(x,d1);
    
    % apply fast givens transformation
    X(row_idx,:) = M'*X(row_idx,:);
    % update diagonal
    d(row_idx,1) = d1;
    
    %disp(X);
end

%R = sqrt(inv(diag(D)))*X;

end