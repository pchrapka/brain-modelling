function [ X ] = givens_fast_lsl(X,m)
%GIVENS_FAST_LSL Fast Givens rotation coefficients
%
%   Input
%   -----
%   X
%       data matrix
%   m
%       number of elements to zero in the first row
%
%   Output 
%   ------
%   X
%       upper triangular mtrix
%
% NOTE Lewis uses the 1983 Golub van Loan and his notation differs
% https://books.google.ca/books?id=mlOa7wPX6OYC&printsec=frontcover&source=gbs_ViewAPI&redir_esc=y#v=onepage&q&f=false
% p.227

[rows,cols] = size(X);
D = ones(rows,1);

% extract elements
%row_idx = sort([i k]);
for j=1:m
    %i=1;
    row_idx = [1 j+1];
    %row_idx = [1 2];
    x = X(row_idx,j);
    d = D(row_idx,1);
    
    % NOTE There is a discrepancy between Lewis and Golub, the Givens
    % rotation in Golub zeros the second element of x
    
    % compute fast Givens transform
    [M, d] = givens_fast_mod_transform(x,d);
    
    % apply fast givens transformation
    X(row_idx,:) = M'*X(row_idx,:);
    % update diagonal
    D(row_idx,1) = d;
    
    disp(X);
end

%R = sqrt(inv(diag(D)))*X;

end