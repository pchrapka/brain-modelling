function [ X ] = givens_lsl(X,m)
%GIVENS_LSL Givens transformation for least squares lattice
%   [X,d] = GIVENS_LSL(X,d,m) zeros the first m elements in the last row
%   of X using the standard Givens transformation
%
%   Example:
%   m = 4
%   X = [ x x x x x x x    G'    X = [ x x x x x x x
%         0 x x x x x x                0 x x x x x x
%         0 0 x x x x x                0 0 x x x x x
%         0 0 0 x x x x                0 0 0 x x x x
%         x x x x x x x]               0 0 0 0 x x x
%   
%   
%   Input
%   -----
%   X
%       upper triangular matrix with a new 1st row
%   m
%       number of elements to zero in the first row
%
%   Output 
%   ------
%   X
%       upper triangular matrix with m zero elements in the first row

rows = size(X,1);

for j=1:m
    row_idx = [j rows];
    x = X(row_idx,j);
    
    % compute Givens transform
    [G,~] = planerot(x);
    
    % apply fast givens transformation
    X(row_idx,:) = G*X(row_idx,:);
end

end