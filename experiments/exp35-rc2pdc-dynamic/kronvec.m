function q = kronvec(B,A,x)
%   (B kron A) x = (B kron A) vec(X)
%                = vec(A X B')
%                = q

X = reshape(x,size(A,2),size(B,2));
Q = A*X*B';
q = Q(:);

end