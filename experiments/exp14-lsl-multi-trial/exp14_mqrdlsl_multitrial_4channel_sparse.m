%% exp14_mqrdlsl_multitrial_4channel_sparse
%
% Goal: Test the multi-trial and multichannel QRD-LSL algorithm with larger
% but sparser coefficients

close all;

nchannels = 4;
ntrials = 10;
nsamples = 200;
norder = 3;

s = VAR(nchannels,norder);
% stable = false;
% while stable == false
%     s.coefs_gen_sparse('mode','probability','probability',0.1);
%     disp(s.A);
%     stable = s.coefs_stable(true);
% end

A = [];
A(:,:,1) = [...
    0         0         0         0;...
    -0.0270   0.2767    0         0;...
    0         0         0         0;...
    0         0         0         0;...
    ];

A(:,:,2) = [...
    0         0         0   -0.7183;...
    0         0         0         0;...
    0.4170    0         0         0;...
    0         0         0         0;...
    ];

A(:,:,3) = [...
    0.2643    0         0         0;...
    0.7388   -0.1545    0         0;...
    0         0         0.9887    0;...
    0         0         0         0;...
    ];
s.coefs_set(A);

% allocate mem for data
x = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [~,x(:,:,i),~] = s.simulate(nsamples);
end

%% Estimate the AR and reflection coefficients using stationary method
% % use all the data
% x_all = reshape(x,nchannels,ntrials*nsamples);

% Simulate long signal to get a good estimate of the true reflection
% coefficients, use lots of samples to get a good estimate of the truth
nsamples_long = 100000;
[~,Y,~] = s.simulate(nsamples_long);

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
    fprintf('Actual\n');
    disp(s.A(:,:,i));
    fprintf('Estimated\n');
    disp(Aest(:,:,i));
    fprintf('\n');
    
    fprintf('Reflection coefficients\n');
    fprintf('Estimated\n');
    disp(squeeze(Kest_stationary(i,:,:)));
    fprintf('\n');
    
end
%display(RC);

% for i=1:4
%     for j=1:4
%         fprintf('i=%d j=%d\n',i,j);
%         disp(Kest_stationary(:,i,j));
%     end
% end

k_true = repmat(Kest_stationary,1,1,1,nsamples);
k_true = shiftdim(k_true,3);

%% Estimate the Reflection coefficients 
%plot_options = {'ch1',2,'ch2',2,'true',k_true};
plot_options = {'mode','3d','true',k_true};

%% MCMTQRDLSL1 with 10 trials
order_est = 3;
verbosity = 1;

lambda = 0.99;
filter = MCMTQRDLSL1(nchannels,order_est,ntrials,lambda);
trace{1} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
plot_options_cust = [plot_options {'title','Multi Trial - All Trials'}];
trace{1}.run(x,'verbosity',verbosity,'mode','plot',...
    'plot_options',plot_options_cust);

%% MCMTQRDLSL1 with 2 trials

lambda = 0.99;
filter = MCMTQRDLSL1(nchannels,order_est,2,lambda);
trace{2} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
plot_options_cust = [plot_options {'title','Multi Trial - 2 Trials'}];
trace{2}.run(x(:,:,1:2),'verbosity',verbosity,'mode','plot',...
    'plot_options',plot_options_cust);

%% Compare to MQRDLSLS1

filter = MQRDLSL1(nchannels,order_est,lambda);
% filter = MQRDLSL2(nchannels,order_est,lambda);
trace{3} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
plot_options_cust = [plot_options {'title','Single Trial'}];
trace{3}.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
    'plot_options',plot_options_cust);

%% Plot MSE
figure;
plot_mse_vs_iteration(...
    trace{1}.trace.Kf, k_true,...
    trace{2}.trace.Kf, k_true,...
    trace{3}.trace.Kf, k_true,...
    'mode','log',...
    'labels',{trace{1}.filter.name,trace{2}.filter.name,trace{3}.filter.name});
