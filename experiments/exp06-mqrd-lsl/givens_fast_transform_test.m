%% givens_fast_transform_test

A = [1;2];
d = [1;1];

fprintf('givens_fast_transform\n');
[M, d1, alpha, beta, type] = givens_fast_transform(A,d);
fprintf('Original\n');
disp(A);
disp(d);
fprintf('After rotation\n');
disp(M'*A);
disp(d1);


fprintf('givens_fast_mod_transform\n');
[M, d1, alpha, beta, type] = givens_fast_mod_transform(A,d);
fprintf('Original\n');
disp(A);
disp(d);
fprintf('After rotation\n');
disp(M'*A);
disp(d1);
