%% exp17_vrc_test_random

clc;
clear all;
close all;

nsamples = 1000;
norder = 3;
nchannels = 4;
ntrials = 1;

s = VRC(nchannels,norder);  
s.coefs_gen_sparse(...
    'structure','fullchannels',...
    'mode','exact',...
    'ncoefs',6,...
    'ncouplings',ceil(6/4),...
    'stable',true,'verbose',1);

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
    
%% Estimate the AR and reflection coefficients using stationary method, Nuttall Strand

[AR,RCF,RCB,PE] = nuttall_strand(Y', norder);
Kf_NS = rcmat2array(RCF);
Kb_NS = rcmat2array(RCB);
Aest = rcmat2array(AR);
fprintf('Method: Nuttall Strand\n');
for i=1:norder
    
    fprintf('order %d\n\n',i);
    fprintf('VAR coefficients\n');
    %fprintf('Actual\n');
    %disp(s.A(:,:,i));
    fprintf('Estimated\n');
    disp(Aest(:,:,i));
    fprintf('\n');
    
    fprintf('Reflection coefficients\n');
    fprintf('Kf:\n');
    fprintf('Actual\n');
    disp(s.Kf(i,:,:));
    fprintf('Estimated\n');
    disp(squeeze(Kf_NS(i,:,:)));
    
    fprintf('Kb:\n');
    fprintf('Actual\n');
    disp(s.Kb(i,:,:));
    fprintf('Estimated\n');
    disp(squeeze(Kb_NS(i,:,:)));
    fprintf('\n');
    
end

%% Compare to MQRDLSLS1
%plot_options = {'ch1',1,'ch2',1,'true',k_true};
kf_true = s.get_rc_time(nsamples,'Kf');
kb_true = s.get_rc_time(nsamples,'Kb');

verbosity = 1;

order_est = norder;
lambda = 0.99;
%filter = MLSL(nchannels,order_est,lambda);
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