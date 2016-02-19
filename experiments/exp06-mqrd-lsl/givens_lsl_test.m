%% givens_lsl_test

rows = 5;
cols = 5;
A = randi([-10 10],rows,cols);
m = 3;
[Q,R] = qr(A);

R = [R; randi([-10 10], 1, cols);];
disp(R)
fprintf('Givens Rotation\n');
givens_lsl(R,m)