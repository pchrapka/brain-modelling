function x = lasso_rls_update2(x,R,r,gamma)

nregressors = length(x);
x = x(:);

if nregressors == 1
    p = 1;
    rp = r(p);
    % eq 19
    %fprintf('rp: %g\ngamma: %g\n',rp,gamma);
    x(p) = sign(rp)/R(p,p)*max((abs(rp) - gamma),0);
else
    
    idx = true(nregressors,1);
    idx(1) = false;
    for p=1:nregressors
        
        % eq 18
        rp = r(p) - R(p,idx)*x(idx);
        
        % eq 19
        %fprintf('rp: %g\ngamma: %g\n',rp,gamma);
        x(p) = sign(rp)/R(p,p)*max((abs(rp) - gamma),0);
        
        idx = circshift(idx,1);
    end
end

end