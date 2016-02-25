function A = gen_var_coefs(K,p)
%GEN_VAR_COEFS generates coefficients for a stable VAR(p) process
%   A = GEN_VAR_COEFS(K,P) generates coefficients for a stable vector
%   autoregressive process of order P with K variables
%
%   Input
%   -----
%   K (integer)
%       process dimension
%   p (integer)
%       model order
%
%   Output
%   ------
%   A (matrix)
%       VAR coefficients, [K K P]

% Source: http://www.kris-nimark.net/pdf/Handout_S1.pdf

lambda = 2.5;
A = zeros(K,K,p);
for i=1:p
    A(:,:,i) = (lambda^(-p))*rand(K,K) - ((2*lambda)^(-p))*ones(K,K);
end

end