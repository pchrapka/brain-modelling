%% lasso_optimize

funcs = {...
    'lasso_rls_update_orig',...
    'lasso_rls_update1',...
    'lasso_rls_update11',...
    'lasso_rls_update12',...
    'lasso_rls_update13',...
    'lasso_rls_update2',...
    };

nchannels = 100;
R = rand(nchannels,nchannels);
r = rand(nchannels,1);
x = rand(nchannels,1);
gamma = 0.1;

niter = 1000;
nfuncs = length(funcs);

xout = {};
for i=1:nfuncs
    fh = str2func(funcs{i});
    
    tstart = tic;
    for k=1:niter
        xout{i} = fh(x,R,r,gamma);
    end
    telapsed = toc(tstart);
    avg_time(i) = telapsed/niter;
    fprintf('%s\n',funcs{i});
    fprintf('\tavg time: %g\n',avg_time(i));
    
    if i~= 1
        fprintf('\timprovement: %0.2f\n',avg_time(1)/avg_time(i));
        if ~isequalntol(xout{i}, xout{1},'AbsTol',eps*10)
            fprintf('\tbad output\n');
        end
    end
end