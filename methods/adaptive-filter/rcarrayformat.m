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
%   informat (string, default = '')
%       input format of coefs
%       'or-ch-ch'
%       'ch-ch-or'
%
%   Output
%   ------
%   out (matrix)
%       coefficient matrix [order,channels,channels]

p = inputParser();
addRequired(p,'coefs',@isnumeric);
addParameter(p,'format',1,@isnumeric);
addParameter(p,'informat','',@(x) any(validatestring(x,{'ch-ch-or','or-ch-ch'})));
addParameter(p,'transpose',false,@islogical);
parse(p,coefs,varargin{:});

switch p.Results.informat
    case 'ch-ch-or'
        format_orig = 3;
        [nchannels,~,norder] = size(coefs);
    case 'or-ch-ch'
        format_orig = 1;
        [norder,nchannels,~] = size(coefs);
    otherwise
        [format_orig,nchannels,norder] = rc_check_format(coefs);
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