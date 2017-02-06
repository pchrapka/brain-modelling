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
% vrc_type = 'vrc-cp-ch2-coupling2-rnd';
% vrc_type_params = {}; % use default
% vrc_gen = VARGenerator(vrc_type, nchannels, 'version', 1);
% if ~vrc_gen.hasprocess
%     vrc_gen.configure(vrc_type_params{:});
% end
% data_vrc = vrc_gen.generate('ntrials',ntrials);
% 
% vrc_data_file = loadfile(vrc_gen.get_file());

% Kf = vrc_data_file.Kf(1,:,:,:);
% Kb = vrc_data_file.Kb(1,:,:,:);

%% set up random matrices
nchannels = 40;
Kf = zeros(1,nchannels,nchannels,norder);
Kf(1,:,:,:) = rand(nchannels,nchannels,norder);
Kb = Kf;

%% dynamic pdc prep

Kftemp = squeeze(Kf(1,:,:,:));
Kbtemp = squeeze(Kb(1,:,:,:));
A2 = -rcarrayformat(rc2ar(Kftemp,Kbtemp),'format',3);

nchannels = size(A2,1);
pf = eye(nchannels);

%% dynamic pdc
niter = 1;
metrics = {...
    'euc',...
    'info',...
    'diag',...
    };
avgtime_benchmark = 1*nchannels^2;
for i=1:length(metrics)
    out = {};
    m = 1;
    metric = metrics{i};
    
    fprintf('pdc profiling for metric: %s\n',metric);
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc_orig(A2,pf,'metric',metric);
%     end
%     m = m+1;
%     telapsed = toc(tstart);
%     avgtime = telapsed/niter;
%     avgtime_benchmark = avgtime;
%     fprintf('pdc time: %e\n',avgtime);
    
%     %pdc2 - uses kronm, slow with reshape operations
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc2(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc2 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
%     
%     % pdc3 - switched freq to inner loop
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc3(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc3 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
%     
%     % pdc4
%     %   - switched freq to inner loop
%     %   - added blkdiag and kroneye speedups
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc4(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc4 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
%     
%     % pdc5
%     %   - freq outer loop
%     %   - used kronvec for Iije
%     %   - used kronvec + blkdiag for Ije
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc5(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc5 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
%     
%     % pdc6
%     %   - freq outer loop
%     %   - used kronvec for Iije
%     %   - used kronvec + blkdiag for Ije
%     %   - avoid recomputing some matrices, applies to diag and info metrics
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc6(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc6 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
%     
%     % pdc7
%   - freq inner loop
%     %   - used kronvec for Iije
%     %   - used kronvec + blkdiag for Ije
%     %   - avoid recomputing some matrices, applies to diag and info metrics
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc7(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc7 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
    
%     % pdc8
%     %   euc
%     %   - freq inner loop
%     %   - Iij
%     %       2012: blkdiag
%     %       2015 kron
%     %   - Ij
%     %       2012: kron + blkdiag
%     %       2015 kron
%     %   info, diag
%     %   - freq inner loop
%     %   - avoid recomputing some matrices, applies to diag and info metrics
%     %   - used kronvec for Iij
%     %   - used kronvec + blkdiag for Ij
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc8(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc8 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
    
%     % pdc9
%     %   euc
%     %   - freq inner loop
%     %   - Iij
%     %       2012: blkdiag
%     %       2015 kron
%     %   - Ij
%     %       2012: kron + blkdiag
%     %       2015 kron
%     %   info, diag
%     %   - freq outer loop
%     %   - avoid recomputing some matrices
%     %   - used kronvec for Iij
%     %   - used kronvec + blkdiag for Ij
%     %   - compute r once per freq
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc9(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc9 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
%     
%     % pdc10
%     %   euc
%     %   - freq outer loop
%     %   - Iij - kronvec
%     %   - Ij - kronvec
%     %   info, diag
%     %   - freq outer loop
%     %   - avoid recomputing some matrices
%     %   - used kronvec for Iij
%     %   - used kronvec + blkdiag for Ij
%     %   - compute r once per freq
%     tstart = tic;
%     for k=1:niter
%         out{m} = pdc10(A2,pf,'metric',metric);
%     end
%     telapsed = toc(tstart);
%     if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
%         fprintf('\tincorrect final answer\n');
%     end
%     m = m+1;
%     avgtime = telapsed/niter;
%     fprintf('pdc10 time: %e\n',avgtime);
%     fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
    
    % pdc11
    %   euc
    %   - freq outer loop
    %   - selector
    %   info, diag
    %   - freq outer loop
    %   - avoid recomputing some matrices
    %   - selector
    %   - compute r once per freq
    tstart = tic;
    for k=1:niter
        out{m} = pdc11(A2,pf,'metric',metric);
    end
    telapsed = toc(tstart);
    if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
        fprintf('\tincorrect final answer\n');
        d = out{m}.pdc - out{1}.pdc;
        fprintf('\t%g\n',norm(d(:)));
    end
    m = m+1;
    avgtime = telapsed/niter;
    fprintf('pdc11 time: %e\n',avgtime);
    fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
    
    % pdc12
    %   euc
    %   - freq outer loop
    %   - selector
    %   - don't duplicate j's
    %   info, diag
    %   - freq outer loop
    %   - avoid recomputing some matrices
    %   - selector
    %   - compute r once per freq
    %   - don't duplicate j's
    tstart = tic;
    for k=1:niter
        out{m} = pdc12(A2,pf,'metric',metric);
    end
    telapsed = toc(tstart);
    if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
        fprintf('\tincorrect final answer\n');
        d = out{m}.pdc - out{1}.pdc;
        fprintf('\t%g\n',norm(d(:)));
    end
    m = m+1;
    avgtime = telapsed/niter;
    fprintf('pdc12 time: %e\n',avgtime);
    fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
    
    % pdc13
    %   euc
    %   - freq outer loop
    %   - selector
    %   - don't duplicate j's
    %   - use selector as index
    %   info, diag
    %   - freq outer loop
    %   - avoid recomputing some matrices
    %   - selector
    %   - compute r once per freq
    %   - don't duplicate j's
    %   - use selector as index
    tstart = tic;
    for k=1:niter
        out{m} = pdc13(A2,pf,'metric',metric);
    end
    telapsed = toc(tstart);
    if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
        fprintf('\tincorrect final answer\n');
        d = out{m}.pdc - out{1}.pdc;
        fprintf('\t%g\n',norm(d(:)));
    end
    m = m+1;
    avgtime = telapsed/niter;
    fprintf('pdc13 time: %e\n',avgtime);
    fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
    
     % pdc14
    %   euc
    %   - freq outer loop
    %   - selector
    %   - don't duplicate j's
    %   - use selector as small index
    %   info, diag
    %   - freq outer loop
    %   - avoid recomputing some matrices
    %   - selector
    %   - compute r once per freq
    %   - don't duplicate j's
    %   - use selector as small index
    tstart = tic;
    for k=1:niter
        out{m} = pdc14(A2,pf,'metric',metric);
    end
    telapsed = toc(tstart);
    if ~isequalntol(out{m}.pdc,out{1}.pdc,'AbsTol',eps*10)
        fprintf('\tincorrect final answer\n');
        d = out{m}.pdc - out{1}.pdc;
        fprintf('\t%g\n',norm(d(:)));
    end
    m = m+1;
    avgtime = telapsed/niter;
    fprintf('pdc14 time: %e\n',avgtime);
    fprintf('improvement: %0.2f\n',avgtime_benchmark/avgtime);
end



