%% exp14_mqrdlsl_multitrial_rc4channel
%
% Goal: Test the MCMTQRDLSLS1 algorithm

clear all;
close all;

nchannels = 4;
ntrials = 10;
nsamples = 200;
norder = 3;

s = VRC(nchannels,norder);

ncoefs = nchannels^2*norder;
sparsity = 0.1;
ncoefs_sparse = ceil(ncoefs*sparsity);
s.coefs_gen_sparse(...
    'structure','fullchannels',...
    'mode','exact',...
    'ncoefs',ncoefs_sparse,...
    'ncouplings',ceil(ncoefs_sparse/4),...
    'stable',true,'verbose',1);

% allocate mem for data
x = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [~,x(:,:,i),~] = s.simulate(nsamples);
end

kf_true = s.get_rc_time(nsamples,'Kf');
kb_true = s.get_rc_time(nsamples,'Kb');

%% MCMTQRDLSL1 with 10 trials
order_est = norder;
verbosity = 2;

lambda = 0.99;
filter = MCMTQRDLSL1(ntrials,nchannels,order_est,lambda);
trace{1} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace{1}.run(x,'verbosity',verbosity,'mode','plot',...
    'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});

[az,el] = view(3);
save_fig_exp(mfilename('fullpath'),'tag','trace1-1');
view(az+90,el);
save_fig_exp(mfilename('fullpath'),'tag','trace1-2');

%% MCMTQRDLSL1 with 2 trials
lambda = 0.99;
filter = MCMTQRDLSL1(2,nchannels,order_est,lambda);
trace{2} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace{2}.run(x(:,:,1:2),'verbosity',verbosity,'mode','plot',...
    'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});

[az,el] = view(3);
save_fig_exp(mfilename('fullpath'),'tag','trace2-1');
view(az+90,el);
save_fig_exp(mfilename('fullpath'),'tag','trace2-2');

%% MQRDLSLS1
lambda = 0.99;
filter = MQRDLSL1(nchannels,order_est,lambda);
% filter = MQRDLSL2(nchannels,order_est,lambda);
trace{3} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
figure;
trace{3}.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
    'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});

[az,el] = view(3);
save_fig_exp(mfilename('fullpath'),'tag','trace3-1');
view(az+90,el);
save_fig_exp(mfilename('fullpath'),'tag','trace3-2');

%% Plot MSE
figure;
plot_mse_vs_iteration(...
    trace{1}.trace.Kf, kf_true,...
    trace{2}.trace.Kf, kf_true,...
    trace{3}.trace.Kf, kf_true,...
    'mode','log',...
    'labels',{trace{1}.filter.name,trace{2}.filter.name,trace{3}.filter.name});

save_fig_exp(mfilename('fullpath'),'tag','mse');

%% Plot grid
% figure;
% trace{1}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
% save_fig_exp(mfilename('fullpath'),'tag','grid1');
% 
% figure;
% trace{2}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
% save_fig_exp(mfilename('fullpath'),'tag','grid2');