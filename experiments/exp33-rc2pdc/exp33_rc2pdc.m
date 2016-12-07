%% exp33-rc2pdc
% test conversion of reflection coefficients to partial directed coherence

nchannels = 4;
norder = 10;
order_est = norder;
lambda = 0.99;

nsamples = 2000;
ntrials = 1;

nsims = 1;
nsims_generate = 2;

%% set up vrc
stable = false;
while ~stable
    % vrc_type = 'vrc-coupling0-fixed';
    % vrc_type_params = {'nsamples',nsamples};
    % vrc_gen = VARGenerator(vrc_type, nsims_generate*ntrials, nchannels, 'version', 'exp33');
    % data_vrc = vrc_gen.generate(vrc_type_params{:});
    %
    % vrc_data_file = loadfile(vrc_gen.get_file());
    % vrc_process = vrc_data_file.process;
    
    vrc_process = VRC(nchannels,norder);
    vrc_process.coefs_gen_sparse('structure','fullchannels',...
        'ncouplings',3,'mode','exact','stable',true,'ncoefs',8);
    
    kf_true = vrc_process.Kf;
    kb_true = vrc_process.Kb;
    
    % convert to AR
    [A,Ab] = rc2ar(kf_true,kb_true);
    
    % check ar by setting up var process
    var = VAR(nchannels,order_est);
    var.coefs_set(rcarrayformat(A,'format',3));
    if var.coefs_stable()
        stable = true;
        fprintf('found coefficients\n');
    else
        fprintf('unstable, searching...\n');
    end
end

data_var = [];
for j=1:nsims_generate*ntrials
    [signal, signal_norm,~] = var.simulate(nsamples);
    data_var.signal(:,:,j) = signal;
    data_var.signal_norm(:,:,j) = signal_norm;
end

%% filter VRC process
% fprintf('filtering...\n');
% filter = MQRDLSL3(nchannels,order_est,lambda);
% trace = LatticeTrace(filter,'fields',{'Kf','Kb'});
% 
% % warmup
% noise = gen_noise(nchannels, nsamples, ntrials);
% trace.warmup(noise);
% 
% trace.warmup(data_vrc.signal(:,:,end));
% 
% % filter it
% trace.run(data_vrc.signal(:,:,1:nsims));
% 
% kf_est = squeeze(trace.trace.Kf(end,:,:,:));
% kb_est = squeeze(trace.trace.Kb(end,:,:,:));


%% filter VAR process, using an RC method
fprintf('filtering...\n');
% filter_check = MQRDLSL3(nchannels,order_est,lambda);
filter_check = BurgVector(nchannels,order_est); % better estimate for stationary data
trace_check = LatticeTrace(filter_check,'fields',{'Kf','Kb'});

% warmup
noise = gen_noise(nchannels, nsamples, ntrials);
trace_check.warmup(noise);

trace_check.warmup(data_var.signal(:,:,end));

% filter it
trace_check.run(data_var.signal(:,:,1:nsims));

kf_check = squeeze(trace_check.trace.Kf(end,:,:,:));
kb_check = squeeze(trace_check.trace.Kf(end,:,:,:));

%% check rc
% checking against the original vrc process
result = isequalntol(kf_check, kf_true,'AbsTol',0.3);

idx = abs(kf_est) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kf is %0.0f%% OK\n',accuracy_percent*100);

result = isequalntol(kb_check, kb_true,'AbsTol',0.3);

idx = abs(kb_est) > 0;
accuracy_percent = sum(result(idx))/length(result(idx));
fprintf('Kb is %0.0f%% OK\n',accuracy_percent*100);


%% compute pdc
% then asymp_pdc