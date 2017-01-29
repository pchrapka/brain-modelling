%% exp35_pdc_optimize
% optimize pdc

%% overall

nchannels = 4;
norder = 10;
order_est = norder;
lambda = 0.99;

nsamples = 500;
ntrials = 1;

%% set up vrc
vrc_type = 'vrc-cp-ch2-coupling2-rnd';
vrc_type_params = {}; % use default
vrc_gen = VARGenerator(vrc_type, nchannels, 'version', 1);
if ~vrc_gen.hasprocess
    vrc_gen.configure(vrc_type_params{:});
end
data_vrc = vrc_gen.generate('ntrials',ntrials);

vrc_data_file = loadfile(vrc_gen.get_file());

%% dynamic pdc prep

Kftemp = squeeze(vrc_data_file.true.Kf(1,:,:,:));
Kbtemp = squeeze(vrc_data_file.true.Kb(1,:,:,:));
A2 = -rcarrayformat(rc2ar(Kftemp,Kbtemp),'format',3);

nchannels = size(A2,1);
pf = eye(nchannels);

%% dynamic pdc
niter = 30;
metric = 'info';
fprintf('pdc profiling for metric: %s\n',metric);
tstart = tic;
for k=1:niter
    out = pdc_orig(A2,pf,'metric',metric);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
avgtime_benchmark = avgtime;
fprintf('pdc time: %e\n',avgtime);

%pdc2 - uses kronm, slow with reshape operations
tstart = tic;
for k=1:niter
    out = pdc2(A2,pf,'metric',metric);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('pdc2 time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

% pdc3 - switched freq to inner loop
tstart = tic;
for k=1:niter
    out = pdc3(A2,pf,'metric',metric);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('pdc3 time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

% pdc4 
%   - switched freq to inner loop
%   - added blkdiag and kroneye speedups
tstart = tic;
for k=1:niter
    out = pdc4(A2,pf,'metric',metric);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('pdc4 time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

% pdc5
%   - freq outer loop
%   - used kronvec for Iije
%   - used kronvec + blkdiag for Ije
tstart = tic;
for k=1:niter
    out = pdc5(A2,pf,'metric',metric);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('pdc5 time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

% pdc6
%   - freq outer loop
%   - used kronvec for Iije
%   - used kronvec + blkdiag for Ije
%   - avoid recomputing some matrices, applies to diag and info metrics
tstart = tic;
for k=1:niter
    out = pdc6(A2,pf,'metric',metric);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('pdc6 time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

% pdc7
%   - freq inner loop
%   - used kronvec for Iije
%   - used kronvec + blkdiag for Ije
%   - avoid recomputing some matrices, applies to diag and info metrics
tstart = tic;
for k=1:niter
    out = pdc7(A2,pf,'metric',metric);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('pdc7 time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);



%% fIij
fprintf('fIij\n');

niter = 10000;
n = 10;
i = 5;
j = 7;
a = randn(2*n^2,1);
m = 1;
b = {};

tstart = tic;
for k=1:niter
    Iij = zeros(1,n^2);
    Iij(n*(j-1)+i) = 1;
    Iij = diag(Iij);
    C = kron(eye(2), Iij);
    b{m} = C*a;
end
m = m+1;
telapsed = toc(tstart);
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
    b{m} = C*a;
end
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('blkdiag avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);

tstart = tic;
for k=1:niter
    Iij = zeros(1,n^2);
    Iij(n*(j-1)+i) = 1;
    Iij = diag(Iij);
    %C = kron(eye(2), Iij);
    b{m} = kronvec(eye(2),Iij,a);
end
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('kronvec avg time: %e\n',avgtime);
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
    b{m} = C*a;
end
m = m+1;
telapsed = toc(tstart);
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
    b{m} = C*a;
end
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
telapsed = toc(tstart);
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
    b{m} = C*a;
end
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
    b{m} = kronvec(blkdiag(Ij,Ij),eye(n),a);
end
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
telapsed = toc(tstart);
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
    b{m} = kronvec(eye(2),kroneye(Ij,n),a);
end
if ~isequal(b{m},b{1})
    fprintf('\tincorrect final answer\n');
end
m = m+1;
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('kronvec+kroneye avg time: %e\n',avgtime);
fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);