function [ R ] = qr_givens_fast(X)
%QR_GIVENS_FAST Fast Givens rotation coefficients
%
%   Input
%   -----
%   X
%       data matrix
%
%   Output
%   ------
%   R
%       upper triangular mtrix
%
% NOTE Lewis uses the 1983 Golub van Loan and his notation differs

[m,n] = size(X);
D = ones(m,1);

% extract elements
%row_idx = sort([i k]);
for j=1:n
    for i=m:-1:j+1
        row_idx = [j i];
        x = X(row_idx,j);
        d = D(row_idx,1);
        
        % compute coefficients
        [M, d] = givens_fast_transform(x,d);
        
        % apply fast givens transformation
        X(row_idx,:) = M'*X(row_idx,:);
        % update diagonal
        D(row_idx,1) = d;
    end
end

R = sqrt(inv(diag(D)))*X;

end