function parfor_close()
%PARFOR_CLOSE closes parallel pool
%   %PARFOR_CLOSE closes parallel pool

if verLessThan('matlab', '8.2.0.29') % R2013b
    if matlabpool('size') > 0
        matlabpool('close');
    end
else
    if ~isempty(gcp)
        delete(gcp);
    end
end


end
