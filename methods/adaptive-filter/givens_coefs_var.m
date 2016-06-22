function X = givens_coefs_var(X,K,p)

error('not working');

rows = size(X,1);


% Zero lower triangle
idx_end = K*(p-1);
% loop over columns
for i=1:idx_end
    % loop over rows
    for j=K*p-1:-1:(K+i)
        row_idx = [j j+1];
        x = X(row_idx,i);
        
        % compute Givens transform
        [G,~] = planerot(x);
        
        % apply fast givens transformation
        X(row_idx,:) = G*X(row_idx,:);
        X
    end
    % Make the bottom entry 1
    X(:,i) = X(:,i)/X(K+i,i);
    X
end

% Zero upper triangle and block
% row-wise bottom to top, column-wise left to right

% % loop over rows
% for i=K*p:-1:K
%     idx_row = K*p - i;
%     % loop over columns
%     for j=K*p:-1:K*(p-1)+1-idx_row
%         col_idx = [j-1 j];
%         x = X(i,col_idx);
%         
%         % compute Givens transform
%         [G,~] = planerot(x');
%         
%         % apply fast givens transformation
%         X(:,col_idx) = X(:,col_idx)*G';
%         X
%     end
%     X(:,j-1) = X(:,j-1)/X(i,j-1);
%     X
% end

% row-wise bottom to top, column-wise right to left
% loop over rows
for i=K*p-1:-1:K
    idx_row = K*p-1 - i
    % loop over columns
    for j=K*p:-1:K*(p-1)+1-idx_row
        row_idx = [i i+1];
        x = X(row_idx,j);
        
        % compute Givens transform
        [G,~] = planerot(x);
        
        % apply fast givens transformation
        X(row_idx,:) = G*X(row_idx,:);
        X
    end
end


end