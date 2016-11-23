function x = lasso_rls_update(x,R,r,gamma)

nregressors = length(x);
x = x(:);

for p=1:nregressors
    idx = true(nregressors,1);
    idx(p) = false;
    
    % eq 18
    if nregressors == 1
        rp = r(p);
    else
        rp = r(p) - R(p,idx)*x(idx);
    end
    
    % eq 19
    x(p) = sign(rp)/R(p,p)*max((abs(rp) - gamma),0);
end

end