function rows = sb_sparse_to_mat(diinsy);

% SB_SPARSE_TO_MAT
%
% $Id: sb_sparse_to_mat.m 8776 2013-11-14 09:04:48Z roboos $

rows = zeros(max(diinsy),1);
rows(diinsy) = 1;
rows = [1;rows];
rows = cumsum(rows);
rows = rows(1:end-1);
end
