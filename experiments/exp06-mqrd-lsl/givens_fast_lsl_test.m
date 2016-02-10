%% givens_fast_lsl_test

rows = 5;
cols = 5;
A = randi([-10 10],rows,cols);
m = 3;
[Q,R] = qr(A);

R = [randi([-10 10], 1, cols); R];
disp(R)
fprintf('Fast Givens Rotation\n');
givens_fast_lsl(R,m)