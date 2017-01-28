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

%% dynamic pdc
niter = 30;
tstart = tic;
for k=1:niter
    Kftemp = squeeze(vrc_data_file.true.Kf(1,:,:,:));
    Kbtemp = squeeze(vrc_data_file.true.Kb(1,:,:,:));
    A2 = -rcarrayformat(rc2ar(Kftemp,Kbtemp),'format',3);
    
    nchannels = size(A2,1);
    pf = eye(nchannels);
    out = pdc(A2,pf,'metric','euc');
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('avg time: %e\n',avgtime);

%% fIij
niter = 1000;
n = 10;
i = 5;
j = 7;

tstart = tic;
for k=1:niter
    Iij = zeros(1,n^2);
    Iij(n*(j-1)+i) = 1;
    Iij = diag(Iij);
    c = kron(eye(2), Iij);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('kron avg time: %e\n',avgtime);

tstart = tic;
for k=1:niter
    Iij = zeros(1,n^2);
    Iij(n*(j-1)+i) = 1;
    Iij = diag(Iij);
    c = blkdiag(Iij,Iij);
    %c = kron(eye(2), Iij);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('blkdiag avg time: %e\n',avgtime);

%% fIj

tstart = tic;
for k=1:niter
    Ij = zeros(1,n);
    Ij(j) = 1;
    Ij = diag(Ij);
    Ij = kron(Ij, eye(n));
    c = kron(eye(2), Ij);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('kron avg time: %e\n',avgtime);

tstart = tic;
for k=1:niter
    Ij = zeros(1,n);
    Ij(j) = 1;
    Ij = diag(Ij);
    Ij = kron(Ij, eye(n));
    c = kron(eye(2), Ij);
end
telapsed = toc(tstart);
avgtime = telapsed/niter;
fprintf('blkdiag avg time: %e\n',avgtime);