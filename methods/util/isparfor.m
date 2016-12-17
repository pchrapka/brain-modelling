function result = isparfor()
%ISPARFOR checks if parallel pool is set up
%   ISPARFOR checks if parallel pool is set up

if verLessThan('matlab', '8.2.0.29') % R2013b
    if matlabpool('size') == 0
        result = false;
    else
        result = true;
    end
else
    pool = gcp('nocreate');
    if isempty(pool) || pool.NumWorkers <= 1
        result = false;
    else
        result = true;
    end
end


end
