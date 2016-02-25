function X = hh_coefs_var(X,K,p)

error('not working');

% % Zero right side
% % loop over rows
% for i=K+1:K*p
%     col_idx = i-K;
%     [v,b] = house(X(i,col_idx:end));
%     v_size = length(v)
%     X(i:end,col_idx:end) = X(i:end,col_idx:end)*(eye(v_size) - b*(v*v'));
%     X
% end

% Bidiagonalization with Householder transformations
% Zero column, zero row
% loop over rows
for i=K+1:K*p
    if i <= K*p -1
        col_idx = i-K;
        % zero column
        [v,b] = house(X(i:end,col_idx));
        v_size = length(v);
        X(i:end,col_idx:end) = (eye(v_size) - b*(v*v'))*X(i:end,col_idx:end);
        X
    end
    
    % zero row
    col_idx = i-K+1;
    [v,b] = house(X(i,col_idx:end));
    v_size = length(v);
    X(i:end,col_idx:end) = X(i:end,col_idx:end)*(eye(v_size) - b*(v*v'));
    X
end

% Zero second diagonal with Givens transformation
for col=K*(p-1)+1:-1:2
    for row=col+K-1:-1:K+1
        row_idx = [row-1 row];
        %x = X(row_idx,col);
        col_idx = [col-1 col];
        x = X(row,col_idx)';
        
        % compute Givens transform
        [G,~] = planerot(x);
        
        % apply fast givens transformation
        %X(row_idx,:) = G*X(row_idx,:);
        X(:,col_idx) = X(:,col_idx)*G';
        X
    end
end

% % Zero lower triangle
% idx_end = K*(p-1)-1;
% % loop over columns
% for i=1:idx_end
%     [v,b] = house(X(K+i:end,i));
%     v_size = length(v)
%     X(K+i:end,i:end) = (eye(v_size) - b*(v*v'))*X(K+i:end,i:end);
%     X
%     %X(K+i+1:end,i) = v(2:end);
%     %X
% end

% % Zero lower triangle, row-wise
% for i=K*p:-1:K+1
%     cold_idx = i;
%     [v,b] = house(fliplr(X(i,1:col_idx)));
%     v_size = length(v)
%     X(
end