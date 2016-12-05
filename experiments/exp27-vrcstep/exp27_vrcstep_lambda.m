%% exp27_vrcstep_lambda
%
% Goal: Test the lattice algos with a step change in reflection
% coefficients, and  varying lambda

close all;

do_plots = false;
do_save = false;

nchannels = 4;
ntrials = 5;
nsamples = 500;
norder = 3;

changepoint= ceil(nsamples/2);
s = VRCStep(nchannels,norder,changepoint);
stable = false;

ncoefs = nchannels^2*norder;
sparsity = 0.1;
ncoefs_sparse = ceil(ncoefs*sparsity);
while ~stable
    s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse);
    stable = s.coefs_stable(true);
end


% allocate mem for data
x = zeros(nchannels,nsamples,ntrials);
for i=1:ntrials
    [~,x(:,:,i),~] = s.simulate(nsamples);
end

% kf_true = repmat(shiftdim(s.Kf,2),1,1,1,nsamples);
% kf_true = shiftdim(kf_true,3);
kf_true = s.get_coefs_vs_time(nsamples,'Kf');
kb_true = s.get_coefs_vs_time(nsamples,'Kb');

% kb_true = repmat(shiftdim(s.Kb,2),1,1,1,nsamples);
% kb_true = shiftdim(kb_true,3);

%% Filter params
order_est = norder;
verbosity = 1;
count = 1;
trace = {};

sigma = 10^(-1);
gamma = [...
    sqrt(2*sigma^2*nsamples*log(nchannels)),...
    sqrt(2*sigma^2*nsamples*log(norder*nchannels^2)),...
    ];


lambda = [0.95 0.98 0.99];
% 0.9 is pretty noisy, very bad for MQRDLSL1
% MQRDLSL1 0.99 is the best
% MLOCCD_TWL faster initial convergence with 0.95, but final MSE is not
% optimal, final MSE doesn't really matter in a time varying use case
% MCMTQRDLSL1 similar to MLOCCD_TWL, 0.98 looks to be best bet here, 0.95
% is a bit faster but much higher MSE

%% MLOCCD_TWL

for j=1:length(lambda)
    for i=1:length(gamma)
        filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda(j),'gamma',gamma(i));
        trace{count} = LatticeTrace(filter,'fields',{'Kf'});
        
        % run the filter
        if do_plots
            figure;
            trace{count}.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
                'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});
        else
            trace{count}.run(x(:,:,1),'verbosity',verbosity);
        end
        
        if do_save
            [az,el] = view(3);
            save_fig_exp(mfilename('fullpath'),'tag','trace1-1');
            view(az+90,el);
            save_fig_exp(mfilename('fullpath'),'tag','trace1-2');
        end
        
        count = count + 1;
    end
end

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

if do_save
    save_fig_exp(mfilename('fullpath'),'tag','mse-MLOCCD_TWL');
end
    
%% MQRDLSL1
count = 1;
trace = {};
for j=1:length(lambda)
    filter = MQRDLSL1(nchannels,order_est,lambda(j));
    trace{count} = LatticeTrace(filter,'fields',{'Kf'});
    
    % run the filter
    if do_plots
        figure;
        trace{count}.run(x(:,:,1),'verbosity',verbosity,'mode','plot',...
            'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});
    else
        trace{count}.run(x(:,:,1),'verbosity',verbosity);
    end
    
    if do_save
        [az,el] = view(3);
        save_fig_exp(mfilename('fullpath'),'tag','trace2-1');
        view(az+90,el);
        save_fig_exp(mfilename('fullpath'),'tag','trace2-2');
    end
    
    count = count + 1;
end

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

if do_save
    save_fig_exp(mfilename('fullpath'),'tag','mse-MQRDLSL1');
end
    
%% MCMTQRDLSL1 5 trials
count = 1;
trace = {};
for j=1:length(lambda)
    mt = 5;
    filter = MCMTQRDLSL1(mt,nchannels,order_est,lambda(j));
    trace{count} = LatticeTrace(filter,'fields',{'Kf'});
    
    % run the filter
    if do_plots
        figure;
        trace{count}.run(x(:,:,1:mt),'verbosity',verbosity,'mode','plot',...
            'plot_options',{'mode','3d','true',kf_true,'fields',{'Kf'}});
    else
        trace{count}.run(x(:,:,1:mt),'verbosity',verbosity);
    end
    
    if do_save
        [az,el] = view(3);
        save_fig_exp(mfilename('fullpath'),'tag','trace2-1');
        view(az+90,el);
        save_fig_exp(mfilename('fullpath'),'tag','trace2-2');
    end
    
    count = count + 1;
end

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

if do_save
    save_fig_exp(mfilename('fullpath'),'tag','mse-MCMTQRDLSL1-mt5');
end

%% Plot grid
% figure;
% trace{1}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
% save_fig_exp(mfilename('fullpath'),'tag','grid1');
% 
% figure;
% trace{2}.plot_trace(nsamples,'mode','grid','true',kf_true,'fields',{'Kf'});
% save_fig_exp(mfilename('fullpath'),'tag','grid2');
