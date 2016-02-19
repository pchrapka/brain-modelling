%% givens_fast_transform_test2

A = [-2*eps 0]';
d = [0 1.0622]';

fprintf('givens_fast_mod_transform\n');
[M, d1, alpha, beta, type] = givens_fast_mod_transform(A,d);
fprintf('Original\n');
disp(A);
disp(d);
fprintf('After rotation\n');
disp(M'*A);
disp(d1);
disp(M'*diag(d)*M);

% Is this good or bad?
% is 