function x = lasso_rls_update13(x,R,r,gamma)

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
    for p=1:nregressors
        rp = r(p) - Rzerodiag(p,:)*x;
        % pth element in Rzerodiag is a zero, so x doesn't need to be zero
        x(p) = sign(rp)./Rdiag(p).*max((abs(rp) - gamma), 0);
    end
end

end