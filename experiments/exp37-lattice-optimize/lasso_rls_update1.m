function x = lasso_rls_update1(x,R,r,gamma)

nregressors = length(x);
x = x(:);

if nregressors == 1
    p = 1;
    rp = r(p);
    % eq 19
    %fprintf('rp: %g\ngamma: %g\n',rp,gamma);
    x(p) = sign(rp)/R(p,p)*max((abs(rp) - gamma),0);
else
    
    for p=1:nregressors
        idx = true(nregressors,1);
        idx(p) = false;
        
        % eq 18
        rp = r(p) - R(p,idx)*x(idx);
        
        % eq 19
        %fprintf('rp: %g\ngamma: %g\n',rp,gamma);
        x(p) = sign(rp)/R(p,p)*max((abs(rp) - gamma),0);
    end
end

end