%% exp17_vrc_test_random

clc;
clear all;
close all;

nsamples = 1000;
norder = 3;
nchannels = 4;
ntrials = 1;

s = VRC(nchannels,norder);
s.coefs_gen_sparse('mode','exact','ncoefs',6);

% allocate mem for data
x = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [~,x(:,:,i),~] = s.simulate(nsamples);
    %[x(:,:,i),~,~] = s.simulate(nsamples);
end

%% Simulate signal

% Simulate long signal to get a good estimate of the true reflection
% coefficients, use lots of samples to get a good estimate of the truth
nsamples_long = 10000;
[~,Y,~] = s.simulate(nsamples_long);

figure;
nsamples_plot = 1000;
for i=1:nchannels
    subplot(nchannels,1,i);
    plot(1:nsamples_plot,Y(i,1:nsamples_plot));
end
    
%% Estimate the AR and reflection coefficients using stationary method

% Estimate reflection coefs using mvar
method = 13;
[AR,RC,PE] = tsa.mvar(Y', norder, method);
Aest = zeros(nchannels,nchannels,norder);
Kest_stationary = zeros(norder,nchannels,nchannels);
for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    Aest(:,:,i) = AR(:,idx_start:idx_end);
    Kest_stationary(i,:,:) = RC(:,idx_start:idx_end);
    
    fprintf('order %d\n\n',i);
    fprintf('VAR coefficients\n');
    %fprintf('Actual\n');
    %disp(s.A(:,:,i));
    fprintf('Estimated\n');
    disp(Aest(:,:,i));
    fprintf('\n');
    
    fprintf('Reflection coefficients\n');
    fprintf('Actual\n');
    fprintf('Kf:\n');
    disp(s.Kf(:,:,i));
    fprintf('Kb:\n');
    disp(s.Kb(:,:,i));
    fprintf('Estimated\n');
    disp(squeeze(Kest_stationary(i,:,:)));
    fprintf('\n');
    
end

%% Compare to MQRDLSLS1
%plot_options = {'ch1',1,'ch2',1,'true',k_true};
kf_true = repmat(shiftdim(s.Kf,2),1,1,1,nsamples);
kf_true = shiftdim(kf_true,3);

kb_true = repmat(shiftdim(s.Kb,2),1,1,1,nsamples);
kb_true = shiftdim(kb_true,3);

verbosity = 0;

order_est = norder;
lambda = 0.99;
% filter = MLSL(nchannels,order_est,lambda);
filter = MQRDLSL1(nchannels,order_est,lambda);
% filter = MQRDLSL2(nchannels,order_est,lambda);
trace = LatticeTrace(filter,'fields',{'Kf','Kb'});

% run the filter
trace.run(x(:,:,1),'verbosity',verbosity);
figure;
for i=1:nsamples
    trace.plot_trace(i,'mode','3d','fields',{'Kf'},'true',kf_true,'title','Kf');
end
figure;
for i=1:nsamples
    trace.plot_trace(i,'mode','3d','fields',{'Kb'},'true',kb_true,'title','Kb');
end

% print details
fprintf('Method: %s\n',filter.name);
for i=1:norder
    fprintf('order %d\n\n',i);
    
    fprintf('Kf:\n');
    fprintf('Actual\n');
    disp(s.Kf(:,:,i));
    fprintf('Estimated\n');
    disp(squeeze(trace.trace.Kf(nsamples,i,:,:)));
    
    fprintf('Kb:\n');
    fprintf('Actual\n');
    disp(s.Kb(:,:,i));
    fprintf('Estimated\n');
    disp(squeeze(trace.trace.Kb(nsamples,i,:,:)));
    fprintf('\n');

end

%% Plot MSE
figure;
plot_mse_vs_iteration(...
    trace.trace.Kf, kf_true,...
    trace.trace.Kb, kb_true,...
    'mode','log',...
    'labels',{'Kf','Kb'});