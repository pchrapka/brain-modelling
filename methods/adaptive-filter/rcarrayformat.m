function out = rcarrayformat(coefs,varargin)
%RCARRAYFORMAT converts between multidimensional matrix formats
%   RCARRAYFORMAT(COEFS,...) converts between multidimensional matrix formats
%
%   Input
%   -----
%   coefs (3d array)
%       coefficient array
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
addRequired(p,'coefs',@(x) length(size(x)) == 3);
addParameter(p,'format',1,@isnumeric);
addParameter(p,'transpose',false,@islogical);
parse(p,coefs,varargin{:});

% check original format
dims = size(coefs);
if dims(1) == dims(2)
    format_orig = 3;
    norder = dims(3);
    nchannels = dims(1);
elseif dims(2) == dims(3)
    format_orig = 1;
    norder = dims(1);
    nchannels = dims(3);
else
    error('unknown coefficient format');
end

if format_orig == p.Results.format
    % in proper format, do nothing
    out = coefs;
    return;
end

% initialize
switch p.Results.format
    case 1
        out = zeros(norder,nchannels,nchannels);
    case 3
        out = zeros(nchannels,nchannels,norder);
    otherwise
        error('unknown format %d',p.Results.format);
end

% convert
for i=1:norder
    switch p.Results.format
        case 1
            out(i,:,:) = transpose_rc(squeeze(coefs(:,:,i)), p.Results.transpose);
        case 3
            out(:,:,i) = transpose_rc(squeeze(coefs(i,:,:)), p.Results.transpose);
    end
end
    

end

function coefs = transpose_rc(coefs,flag)
if flag
    coefs = coefs';
end
end