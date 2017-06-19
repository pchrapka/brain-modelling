function [format,nchannels,norder] = rc_check_format(coefs)
% check original format
dims = size(coefs);
if length(dims) < 3
    dims(3) = 1;
end
if dims(1) == dims(2)
    format = 3;
    norder = dims(3);
    nchannels = dims(1);
elseif dims(2) == dims(3)
    format = 1;
    norder = dims(1);
    nchannels = dims(3);
else
    error('unknown coefficient format');
end

end