function parfor_close()
%PARFOR_CLOSE closes parallel pool
%   %PARFOR_CLOSE closes parallel pool

if verLessThan('matlab', '8.2.0.29') % R2013b
    matlabpool('close');
else
    if ~isempty(gcp)
        delete(gcp);
    end
end


end
