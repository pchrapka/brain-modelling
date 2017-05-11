function [yq,xq] = interp1_nosort(x,y,xq,varargin)

x = x(:);
y = y(:);
xq = xq(:);

nx = length(x);

x1 = x(1);
y1 = y(1);

yq = [];
xq_out = [];
for i=2:nx
    x2 = x(i);
    y2 = y(i);
    
    idx1 = (xq >= x1) & (xq <= x2);
    idx2 = (xq <= x1) & (xq >= x2);
    if sum(idx1) ~= 0
        xq_seg = xq(idx1);
    elseif sum(idx2) ~= 0
        xq_seg = xq(idx2);
        xq_seg = flipdim(xq_seg,1);
    else
        xq_seg = [];
    end
    yq_seg = interp1([x1 x2],[y1 y2],xq_seg,varargin{:});
    xq_out = [xq_out; xq_seg];
    yq = [yq; yq_seg];
    
    x1 = x2;
    y1 = y2;
end
xq = xq_out;

end