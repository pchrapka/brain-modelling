%% exp16_l1_lsl_1channel_benchmark
%
% Goal: Test the L1 LSL algorithms against each other

close all;

nsims = 20;%200;
nchannels = 1;
ntrials = 1;
nsamples = 200;

plot_mode = 'none';
verbosity = 0;

trace = cell(2,nsims);
kf_true_sims = cell(nsims,1);

for j=1:nsims
    fprintf('sim: %d\n',j);
    
    count = 1;
    
    %% generate sparse VAR process
    ncoefs = 3;
    norder = 30;
    sparsity = ncoefs/norder;
    
    s = VRC(nchannels,norder);
    s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs);
    stable = false;
    while stable == false
        s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs);
        stable = s.coefs_stable(false);
    end
    disp(reshape(s.Kf,1,norder));
    
    % allocate mem for data
    x = zeros(nchannels,nsamples,ntrials);
    for i=1:ntrials
        [x(:,:,i),~,~] = s.simulate(nsamples);
    end
    
    %figure;
    %plot(1:nsamples,squeeze(x(:,:,1)));
    
    %% Set plot params
    % coefs_true = shiftdim(coefs,2);
    % kf_true = repmat(coefs_true,1,1,1,nsamples);
    % kf_true = shiftdim(kf_true,3);
    
    coefs_true = shiftdim(s.Kf,2);
    kf_true = repmat(coefs_true,1,1,1,nsamples);
    kf_true = shiftdim(kf_true,3);
    kf_true_sims{j} = kf_true;
    
    % k_est_mat(:,1,1) = k_est;
    % k_true = repmat(-1*k_est_mat,1,1,1,nsamples);
    % k_true = shiftdim(k_true,3);
    
    %plot_options = {'ch1',1,'ch2',1,'true',kf_true,'fields',{'Kf'}}
    plot_options = {'mode','3d','true',kf_true,'fields',{'Kf'}};
    
    order_est = norder;
    
    %% Estimate the R coefficients using MQRDLSL
    lambda = 0.99;
    filter = MQRDLSL1(nchannels,order_est,lambda);
    trace{count,j} = LatticeTrace(filter,'fields',{'Kf'});
    
    % run the filter
    if isequal(plot_mode,'plot')
        figure;
    end
    trace{count,j}.run(x,'verbosity',verbosity,'mode',plot_mode,...
        'plot_options',plot_options);
    
    count = count + 1;
    
    %% Estimate the R coefficients using MLOCCD_TWL
    sigma = 10^(-1);
    gamma = sqrt(2*sigma^2*nsamples*log(norder*nchannels^2));
    lambda = 0.99;
    % NOTE This algo breaks down for 1 channel, there is only one regressor
    % per order so 
    filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
    trace{count,j} = LatticeTrace(filter,'fields',{'Kf'});
    
    % run the filter
    if isequal(plot_mode,'plot')
        figure;
    end
    trace{count,j}.run(x,'verbosity',verbosity,'mode',plot_mode,...
        'plot_options',plot_options);
    
    count = count + 1;
    
end


%% Plot MSE
nfilters = size(trace,1);
estimate = cell(nfilters,nsims);
labels = cell(nfilters,1);
data_args = {};
for i=1:nfilters
    labels{i} = strrep(trace{i}.filter.name,'_',' ');
    for j=1:nsims
        estimate{i,j} = trace{i,j}.trace.Kf;
    end
    data_args = [data_args {estimate(i,:), kf_true_sims}];
end

figure;
plot_mse_vs_iteration(...
    data_args{:},...
    'mode','log',...
    'labels',labels);
save_fig_exp(mfilename('fullpath'),'tag','mse');

figure;
plot_mse_vs_iteration(...
    data_args{:},...
    'mode','log',...
    'labels',labels,...
    'normalized',true);
save_fig_exp(mfilename('fullpath'),'tag','nmse');