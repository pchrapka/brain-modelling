%% exp16_mloccd_tnwl_rc4channel
%
%   Goal: Test the MLOCCD-TNWL algorithm
%
%   Results: Not much of a difference between TNWL and TWL. Depending on a
%   TNWL can preform worse than TWL. It seems like TWL is the upper limit.
%
%   NOTE
%   There may be implementation issues with the method that computes the
%   weight, since the papers omits the details for the online TNWL algos

close all;
clear all;

do_plots = false;
do_save = false;

nchannels = 4;
ntrials = 1;
nsamples = 500;
norder = 3;

s = VRC(nchannels,norder);
stable = false;

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

%% Filter params
order_est = norder;
verbosity = 2;
count = 1;
%a = [1.5, 3, 6, 9];
% a = [1.5 10 20];
a = [2 20 40];
trace = {};

sigma = 10^(-1);
% gamma = sqrt(2*sigma^2*nsamples*log(norder*nchannels^2));
gamma = sqrt(2*sigma^2*nsamples*log(nchannels));

%% Estimate the Reflection coefficients using MLOCCD_TNWL
for i=1:length(a)
    lambda = 0.99;
    filter = MLOCCD_TNWL(nchannels,order_est,'lambda',lambda,'gamma',gamma,'a',a(i));
    trace{count} = LatticeTrace(filter,'fields',{'Kf'});
    
    % run the filter
    if do_plots
        figure;
        trace{count}.run(x,'verbosity',verbosity,'mode','plot',...
            'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});
    else
        trace{count}.run(x,'verbosity',verbosity);
    end
    
    if do_save
        [az,el] = view(3);
        save_fig_exp(mfilename('fullpath'),'tag','trace1-1');
        view(az+90,el);
        save_fig_exp(mfilename('fullpath'),'tag','trace1-2');
    end
    
    count = count + 1;
end

%% Compare with MLOCCD_TWL
lambda = 0.99;
filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
trace{count} = LatticeTrace(filter,'fields',{'Kf'});

if do_plots
    figure;
    trace{count}.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
        'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});
else
    trace{count}.run(x,'verbosity',verbosity);
end

if do_save
    [az,el] = view(3);
    save_fig_exp(mfilename('fullpath'),'tag','trace2-1');
    view(az+90,el);
    save_fig_exp(mfilename('fullpath'),'tag','trace2-2');
end

count = count + 1;

%% Compare with MQRDLSL
filter = MQRDLSL1(nchannels,order_est,lambda);
trace{count} = LatticeTrace(filter,'fields',{'Kf'});

% run the filter
if do_plots
    figure;
    trace{count}.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
        'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});
else
    trace{count}.run(x,'verbosity',verbosity);
end

if do_save
    [az,el] = view(3);
    save_fig_exp(mfilename('fullpath'),'tag','trace2-1');
    view(az+90,el);
    save_fig_exp(mfilename('fullpath'),'tag','trace2-2');
end

count = count + 1;

%% Plot MSE
data_args = {};
labels = {};
for i=1:length(trace)
    data_args = [data_args trace{i}.trace.Kf kf_true];
    labels = [labels trace{i}.filter.name];
end

figure;
plot_mse_vs_iteration(...
    data_args{:},...
    'mode','log',...
    'labels',labels);

% figure;
% plot_mse_vs_iteration(trace{1}.trace.Kf, kf_true,'mode','log','labels',{trace{1}.filter.name});

% save_fig_exp(mfilename('fullpath'),'tag','mse');

%% Plot grid
figure;
trace{length(a)}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
if do_save
    % save_fig_exp(mfilename('fullpath'),'tag','grid1');
end

figure;
trace{end-1}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
if do_save
    % save_fig_exp(mfilename('fullpath'),'tag','grid2');
end

figure;
trace{end}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
if do_save
    % save_fig_exp(mfilename('fullpath'),'tag','grid2');
end