function x = lasso_rls_update12(x,R,r,gamma)

nregressors = length(x);
x = x(:);

if nregressors == 1
    rp = r;
    % eq 19
    %fprintf('rp: %g\ngamma: %g\n',rp,gamma);
    x = sign(rp)/R*max((abs(rp) - gamma),0);
else
    
    Rdiag = diag(R);
    Rzerodiag = R - diag(Rdiag);
    X = repmat(x',nregressors,1);
    rp = r - sum(Rzerodiag.*X,2);
    x = sign(rp)./Rdiag.*max((abs(rp) - gamma), zeros(nregressors,1));
    % bad output because x updates are recursive
end

end