%% exp16_mloccd_twl_rc4channel
%
% Goal: Test the MLOCCD-TWL algorithm

close all;

nchannels = 4;
ntrials = 1;
nsamples = 500;
norder = 3;

s = VRC(nchannels,norder);
% stable = false;
% while stable == false
%     s.coefs_gen_sparse('mode','probability','probability',0.1);
%     disp(s.A);
%     stable = s.coefs_stable(true);
% end

ncoefs = nchannels^2*norder;
sparsity = 0.1;
ncoefs_sparse = ceil(ncoefs*sparsity);
s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse);

% allocate mem for data
x = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [~,x(:,:,i),~] = s.simulate(nsamples);
end
% 
% %% Estimate the AR and reflection coefficients using stationary method
% % % use all the data
% % x_all = reshape(x,nchannels,ntrials*nsamples);
% 
% % Simulate long signal to get a good estimate of the true reflection
% % coefficients, use lots of samples to get a good estimate of the truth
% nsamples_long = 100000;
% [~,Y,~] = s.simulate(nsamples_long);
% 
% % Estimate reflection coefs using mvar
% method = 13;
% [AR,RC,PE] = tsa.mvar(Y', norder, method);
% Aest = zeros(nchannels,nchannels,norder);
% Kest_stationary = zeros(norder,nchannels,nchannels);
% for i=1:norder
%     idx_start = (i-1)*nchannels+1;
%     idx_end = i*nchannels; 
%     Aest(:,:,i) = AR(:,idx_start:idx_end);
%     Kest_stationary(i,:,:) = RC(:,idx_start:idx_end);
%     
%     fprintf('order %d\n\n',i);
%     fprintf('VAR coefficients\n');
%     fprintf('Actual\n');
%     disp(s.A(:,:,i));
%     fprintf('Estimated\n');
%     disp(Aest(:,:,i));
%     fprintf('\n');
%     
%     fprintf('Reflection coefficients\n');
%     fprintf('Estimated\n');
%     disp(squeeze(Kest_stationary(i,:,:)));
%     fprintf('\n');
%     
% end
% 
% k_true = repmat(Kest_stationary,1,1,1,nsamples);
% k_true = shiftdim(k_true,3);
% 
% coefs_true = shiftdim(A,2);
% a_true = repmat(coefs_true,1,1,1,nsamples);
% a_true = shiftdim(a_true,3);

kf_true = repmat(shiftdim(s.Kf,2),1,1,1,nsamples);
kf_true = shiftdim(kf_true,3);

kb_true = repmat(shiftdim(s.Kb,2),1,1,1,nsamples);
kb_true = shiftdim(kb_true,3);

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
    'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});

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
    'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});

[az,el] = view(3);
save_fig_exp(mfilename('fullpath'),'tag','trace2-1');
view(az+90,el);
save_fig_exp(mfilename('fullpath'),'tag','trace2-2');

%% Plot MSE
figure;
plot_mse_vs_iteration(...
    trace{1}.trace.Kf, kf_true,...
    trace{2}.trace.Kf, kf_true,...
    'mode','log',...
    'labels',{trace{1}.filter.name,trace{2}.filter.name});

save_fig_exp(mfilename('fullpath'),'tag','mse');

%% Plot grid
figure;
trace{1}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
figure;
trace{2}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
