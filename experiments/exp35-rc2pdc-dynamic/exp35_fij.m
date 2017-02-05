%% exp35_fij

%% fIij
fprintf('fIij\n');

% niter = 10000;
% n = 5;

niter = 10;
n = 100;

i = randsample(n,1);
j = randsample(n,1);
a = 1:2*(n^2);
% a = [a a];
% a = a(:);
a = randn(2*n^2,1);
m = 1;
b = {};

disp(i);
disp(j);

tstart = tic;
for k=1:niter
    Iij = zeros(1,n^2);
    Iij(n*(j-1)+i) = 1;
    Iij = diag(Iij);
    C = kron(eye(2), Iij);
    b{m} = a'*C*a;
end
telapsed = toc(tstart);
m = m+1;
avgtime = telapsed/niter;
avgtime_benchmark = avgtime;
fprintf('kron avg time: %e\n',avgtime);

tstart = tic;
for k=1:niter
    Iij = zeros(1,n^2);
    Iij(n*(j-1)+i) = 1;
    Iij = diag(Iij);
    C = blkdiag(Iij,Iij);
    %C = kron(eye(2), Iij);
    b{m} = a'*C*a;
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('blkdiag avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    Iij = zeros(1,n^2);
    Iij(n*(j-1)+i) = 1;
    Iij = diag(Iij);
    %C = kron(eye(2), Iij);
    b{m} = a'*kronvec(eye(2),Iij,a);
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('kronvec avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    select = false(n^2,1);
    select(n*(j-1)+i) = true;
    select = [select; select];
    b{m} = a'* (select.*a);
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('method1 avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    select = false(n^2,1);
    select(n*(j-1)+i) = true;
    select = [select; select];
    c = a(select);
    b{m} = c'*c;
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('method2 avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    select = zeros(2,1);
    select(1) = n*(j-1)+i;
    select(2) = n^2 + select(1);
    c = a(select);
    b{m} = c'*c;
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('method3 avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

%% fIj
fprintf('fIj\n');
m = 1;
b = {};

tstart = tic;
for k=1:niter
    Ij = zeros(1,n);
    Ij(j) = 1;
    Ij = diag(Ij);
    Ij = kron(Ij, eye(n));
    C = kron(eye(2), Ij);
    b{m} = a'*C*a;
end
telapsed = toc(tstart);
m = m+1;
avgtime = telapsed/niter;
avgtime_benchmark = avgtime;
fprintf('kron avg time: %e\n',avgtime);

tstart = tic;
for k=1:niter
    Ij = zeros(1,n);
    Ij(j) = 1;
    Ij = diag(Ij);
    Ij = kron(Ij, eye(n));
    %C = kron(eye(2), Ij);
    C = blkdiag(Ij,Ij);
    b{m} = a'*C*a;
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('blkdiag avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    Ij = zeros(1,n);
    Ij(j) = 1;
    Ij = diag(Ij);
    %Ij = kron(Ij, eye(n));
    Ij = kroneye(Ij,n);
    %C = kron(eye(2), Ij);
    C = blkdiag(Ij,Ij);
    b{m} = a'*C*a;
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('blkdiag+kroneye avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    Ij = zeros(1,n);
    Ij(j) = 1;
    Ij = diag(Ij);
    %Ij = kron(Ij, eye(n));
    %C = kron(eye(2), Ij);
    b{m} = a'*kronvec(blkdiag(Ij,Ij),eye(n),a);
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('kronvec+blkdiag avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    Ij = zeros(1,n);
    Ij(j) = 1;
    Ij = diag(Ij);
    %Ij = kron(Ij, eye(n));
    %C = kron(eye(2), Ij);
    b{m} = a'*kronvec(eye(2),kroneye(Ij,n),a);
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('kronvec+kroneye avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    select = false(n^2,1);
    idxbeg = (j-1)*n+1;
    idxend = idxbeg + n -1;
    select(idxbeg:idxend) = true;
    select = [select; select];
    b{m} = a'*(a.*select);
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('method1 avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    select = false(n^2,1);
    idxbeg = (j-1)*n+1;
    idxend = idxbeg + n -1;
    select(idxbeg:idxend) = true;
    select = [select; select];
    c = a(select);
    b{m} = c'*c;
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('method2 avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    idxbeg = (j-1)*n+1;
    idxend = idxbeg + n -1;
    idxbeg2 = idxbeg + n^2;
    idxend2 = idxend + n^2;
    select = [(idxbeg:idxend)'; (idxbeg2:idxend2)'];
    c = a(select);
    b{m} = c'*c;
end
telapsed = toc(tstart);
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
avgtime = telapsed/niter;
fprintf('method3 avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);