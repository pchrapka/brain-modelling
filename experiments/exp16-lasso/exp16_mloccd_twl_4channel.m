%% exp16_mloccd_twl_4channel
%
% Goal: Test the MLOCCD-TWL algorithm

close all;

nchannels = 4;
ntrials = 1;
nsamples = 500;
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

k_true = repmat(Kest_stationary,1,1,1,nsamples);
k_true = shiftdim(k_true,3);

coefs_true = shiftdim(A,2);
a_true = repmat(coefs_true,1,1,1,nsamples);
a_true = shiftdim(a_true,3);

%% Estimate the Reflection coefficients using MLOCCD_TWL
order_est = norder;
verbosity = 2;

sigma = 10^(-1);
gamma = sqrt(2*sigma^2*nsamples*log(norder*nchannels^2));
lambda = 0.99;
filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
trace{1} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace{1}.run(x,'verbosity',verbosity,'mode','plot',...
    'plot_options',{'mode','3d','true',k_true,'fields',{'Kf'}});

[az,el] = view(3);
save_fig_exp(mfilename('fullpath'),'tag','trace1-1');
view(az+90,el);
save_fig_exp(mfilename('fullpath'),'tag','trace1-2');

%% Compare with MQRDLSL
filter = MQRDLSL1(nchannels,order_est,lambda);
% filter = MQRDLSL2(nchannels,order_est,lambda);
trace{2} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace{2}.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
    'plot_options',{'mode','3d','true',k_true,'fields',{'Kf'}});

[az,el] = view(3);
save_fig_exp(mfilename('fullpath'),'tag','trace2-1');
view(az+90,el);
save_fig_exp(mfilename('fullpath'),'tag','trace2-2');

%% Plot MSE
figure;
plot_mse_vs_iteration(...
    trace{1}.trace.Kf, k_true,...
    trace{2}.trace.Kf, k_true,...
    'mode','log',...
    'labels',{trace{1}.filter.name,trace{2}.filter.name});

save_fig_exp(mfilename('fullpath'),'tag','mse');

%% Compare to AR coefs
RC_cell = squeeze(trace{2}.trace.Kf(end,:,:,:));
RC_est = zeros(nchannels,nchannels*norder);
for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    RC_est(:,idx_start:idx_end) = RC_cell(i,:,:);
end
[AR_lsl,~,~,~] = tsa.rc2ar(RC_est);

for i=1:norder
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    
    fprintf('order %d\n',i);
    fprintf('Truth\n');
    disp(A(:,:,i));
    fprintf('Nuttall Strand\n');
    disp(AR(:,idx_start:idx_end));
    fprintf('LSL\n');
    disp(AR_lsl(:,idx_start:idx_end));
end