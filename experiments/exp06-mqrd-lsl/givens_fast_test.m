%% givens_fast_test
B = [1; 2];
[X,D,M] = givens_fast(1,1,B,[])

A = [6 5 4; 5 1 4; 2 4 3; 1 2 7];
m = size(A,1); % rows
n = size(A,2); % cols

fprintf('Fast Givens Rotation\n');
% X = A;
% D = [];
% for j=1:ncmds
%     i=cmds(j,1);
%     k=cmds(j,2);
%     fprintf('annihilating (%d,%d) in\nX =\n',i,k);
%     disp(X);
%     
%     [X, D, M] = givens_fast(i,k,X,D)
% end

% X = A;
% D = [];
% for j=1:n
%     for i=m:-1:j+1
%         fprintf('i=%d j=%d\n',i,j);
%         fprintf('1: A(%d:%d, %d)\n',i-1,i,j);
%         fprintf('annihilating (%d,%d) in\nX =\n',i,k);
%     disp(X);
%     
%       % NOTE I would need to change the inside of givens fast
%     [X, D, M] = givens_fast(i,k,X,D)
%     end
% end

% X = A;
% D = [];
% for j=1:n
%     for i=m:-1:j+1
%         fprintf('i=%d j=%d\n',i,j);
%         fprintf('2: A(%d,%d, %d)\n',j,i,j);
%         fprintf('annihilating (%d,%d) in\nX =\n',i,k);
%         disp(X);
%         
%         [X, D, M] = givens_fast(i,k,X,D)
%     end
% end

fprintf('Fast QR decomposition\n');
qr_givens_fast(A)

fprintf('QR decomposition\n');
[Q,R] = qr(A)