function out = rcmat2array(coefs,varargin)
%RCMAT2ARRAY converts a 2d reflection coefficient matrix to a
%multidimensional matrix
%   RCMAT2ARRAY(COEFS) converts a 2d reflection coefficient matrix to a
%   multidimensional matrix
%
%   Input
%   -----
%   coefs (matrix)
%       coefficient matrix, [channels, order*channels]
%
%   Parameters
%   ----------
%   format (integer, default = 1)
%       output format
%       1 => [order,channels,channels]
%       3 => [channels,channels,order]
%
%   Output
%   ------
%   out (matrix)
%       coefficient matrix [order,channels,channels]

p = inputParser();
addRequired(p,'coefs',@ismatrix);
addParameter(p,'format',1,@isnumeric);
parse(p,coefs,varargin{:});


nchannels = size(coefs,1);
norder = size(coefs,2)/nchannels;

switch p.Results.format
    case 1
        out = zeros(norder,nchannels,nchannels);
    case 3
        out = zeros(nchannels,nchannels,norder);
    otherwise
        error('unknown format %d',p.Results.format);
end

for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels;
    switch p.Results.format
        case 1
            out(i,:,:) = coefs(:,idx_start:idx_end);
        case 3
            out(:,:,i) = coefs(:,idx_start:idx_end);
    end
end
    

end