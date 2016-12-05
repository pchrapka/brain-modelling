%% exp33-rc2pdc
% test conversion of reflection coefficients to partial directed coherence

nchannels = 4;
norder = 10;
order_est = norder;
lambda = 0.99;

nsamples = 2000;
ntrials = 1;

%% set up vrc 
nsims = 1;
nsims_generate = 2;
vrc_type = 'vrc-coupling0-fixed';
vrc_type_params = {'nsamples',nsamples};
vrc_gen = VARGenerator(vrc_type, nsims_generate*ntrials, nchannels, 'version', 'exp33');
data_vrc = vrc_gen.generate(vrc_type_params{:});

%% filtering
filter = MQRDLSL3(nchannels,order_est,lambda);
trace = LatticeTrace(filter,'fields',{'Kf','Kb'});

% warmup
noise = gen_noise(nchannels, nsamples, ntrials);
trace.warmup(noise);

trace.warmup(data_vrc.signal(:,:,end));

% filter it
trace.run(data_vrc.signal(:,:,1:nsims));

kf = squeeze(trace.trace.Kf(end,:,:,:));
kb = squeeze(trace.trace.Kb(end,:,:,:));

%% rc2ar
rc(:,:,1) = eye(nchannels);
rc(:,:,2:norder+1) = rcarrayformat(kf,'format',3);
rcb(:,:,1) = eye(nchannels);
rcb(:,:,2:norder+1) = rcarrayformat(kb,'format',3);
[par, parb] = rc2parv(rc,rcb);

%% set up var for check

% check ar by setting up var process
var = VAR(nchannels,order_est);
var.coefs_set(par(:,:,2:end));
data_var = [];
for j=1:nsims_generate*ntrials
    [signal, signal_norm,~] = var.simulate(nsamples);
    data_var.signal(:,:,j) = signal;
    data_var.signal_norm(:,:,j) = signal_norm;
end

%% filtering, using an RC method
filter_check = MQRDLSL3(nchannels,order_est,lambda);
trace_check = LatticeTrace(filter_check,'fields',{'Kf','Kb'});

% warmup
noise = gen_noise(nchannels, nsamples, ntrials);
trace_check.warmup(noise);

trace_check.warmup(data_var.signal(:,:,end));

% filter it
trace_check.run(data_var.signal(:,:,1:nsims));

%% check rc
% checking against the original vrc process
kf_check = squeeze(trace_check.trace.Kf(end,:,:,:));
result = isequalntol(kf_check, kf);

idx = abs(kf) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kf is %0.0f%% OK\n',accuracy_percent*100);

kb_check = squeeze(trace_check.trace.Kf(end,:,:,:));
result = isequalntol(kb_check, kb);

idx = abs(kb) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kb is %0.0f%% OK\n',accuracy_percent*100);


%% compute pdc
% then asymp_pdc