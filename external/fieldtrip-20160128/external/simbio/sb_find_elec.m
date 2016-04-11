function diri = sb_find_elec(vol,sens)

% SB_FIND_ELEC
%
% $Id: sb_find_elec.m 8776 2013-11-14 09:04:48Z roboos $

diri = zeros(size(sens.elecpos,1),1);
for i=1:size(sens.elecpos,1)
    [dist, diri(i)] = min(sum(bsxfun(@minus,vol.pos,sens.elecpos(i,:)).^2,2));
end
end
