% exp19_krls_anomaly_eeg
% KRLS-T anomaly detection algorithm for EEG data
%
% Adapted from the Kernel Adaptive Filtering Toolbox for Matlab.
% http://sourceforge.net/projects/kafbox/

%close all;
% clear all;

%% PARAMETERS

% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% horizon = 1; % prediction horizon
embedding = 8; % time-embedding
% N = 500; % number of data

params_estimate = false;

% beamformed data
files_std = fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat');
files_odd = fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat');

%% load training data
data_std = load(files_std);
ntrials = length(data_std.sourceanalysis_all);

% set up training label
train_label = 1;
ntrials_test = 20;

%% train KRLS


fprintf(1,'Running KRLS-T with hard coded parameters...\n');

switch embedding
    case 2
        rho = 0.01;
        sigma = 0.65;
        lambda = 1;
    case 6
        %         rho = 0.01;
        %         sigma = 2;
        %         lambda = 1;
        
        rho = 0.01;
        sigma = 2;
        lambda = 0.999;
    case 8
        rho = 0.01;
        sigma = 8;%good
%         sigma = 10;%good
        % higher sigma gets worse
        lambda = 1;
%         lambda = 0.999;%also good
    otherwise
        error('figure params for this embedding');
end
kaf = krlst(struct('lambda',lambda,'M',100,'sn2',rho,...
    'kerneltype','gauss','kernelpar',sigma));

h = figure;
Y_est_mean = [];
for j=1:ntrials_test%ntrials
    
    % format trial data
    trial_struct = data_std.sourceanalysis_all(j);
    trial_data = cell2mat(trial_struct.avg.mom(trial_struct.inside)); % channels x time
    
    % select post stim data
    idx_time = data_std.sourceanalysis_all(j).time >= 0;
    trial_data(:,~idx_time) = [];
    
    nsamples = size(trial_data,2);
    
    % set up training labels
    Y = repmat(train_label,nsamples,1);
    
    % allocate mem
    Y_est = zeros(nsamples,1);
    Yvar_est = zeros(nsamples,1);
    
    % set up counters
    idx_end = embedding;
    
    N = nsamples-embedding+1;
    for i=1:N
        % progress indicator, 10 dots
        if ~mod(i,floor(nsamples/10))
            fprintf('.'); 
        end 
        
        % set current sample
        x = trial_data(:,i:idx_end);
        % reshape x into a vector arranged by channel
        %   [x_ch1 x_ch2 ... x_chN]
        x = reshape(x',1,numel(x));
        
        % train KRLS
        [Y_est(i), Yvar_est(i)] = kaf.evaluate(x); % predict the next output
        kaf = kaf.train(x,Y(i)); % train with one input-output pair
        
        % increment counters
        idx_end = i + embedding;
    end
    
    if j == 1
        Y_est_mean = Y_est;
        Yvar_mean = Yvar_est;
    else
        Y_est_mean = Y_est_mean + Y_est;
        Yvar_mean = Yvar_mean + Yvar_est;
    end
    
    fprintf('\n');
    SE = (Y-Y_est).^2; % square error
    
    fprintf('Average MSE: %.2fdB\n\n',...
        10*log10(mean(SE)));
    
    figure(h); 
    
    plot(Y); 
    hold on;
    plot(Y_est);
    hold on;
    t = (1:length(Y_est))';
    z = patch([t; flipud(t)], [Y_est+Yvar_est; flipud(Y_est-Yvar_est)], 'r');
    for i=1:length(z)
        set(z(i),'FaceAlpha',0.3);
        set(z(i),'EdgeColor','None');
    end
    
    legend({'original','prediction'},'Location','SE');
    ylim([-0.5 1.5]);
    title(sprintf('%s AD on Standard stimulus - Trial %d',...
        upper(class(kaf)),j));
    hold off;
end

Y_est_mean = Y_est_mean/ntrials_test;
Yvar_mean = Yvar_mean/(ntrials_test^2);
h1 = figure;
plot(Y,'-b'); 
hold on;
plot(Y_est_mean,'-r');

t = (1:length(Y_est_mean))';
hold on;
z = patch([t; flipud(t)], [Y_est_mean+Yvar_mean; flipud(Y_est_mean-Yvar_mean)], 'r');
for i=1:length(z)
    set(z(i),'FaceAlpha',0.3);
    set(z(i),'EdgeColor','None');
end
legend({'original','average'},'Location','SE');
ylim([-0.5 1.5]);
title(sprintf('Average %s AD on Standard stimulus',...
    upper(class(kaf))));
hold off;

% toc
%% OUTPUT

% fprintf('\n');
% fprintf('        Estimated\n');
% fprintf('sigma:  %.4f\n',sigma_est)
% fprintf('c:      %e\n',reg_est)
% fprintf('lambda: %.4f\n\n',lambda_est)

% fprintf('Average MSE after first 100 samples: %.2fdB\n\n',...
%     10*log10(mean(SE(101:end))));
% 
% figure; hold all; plot(Y); plot(Y_est);
% legend({'original','prediction'},'Location','SE');
% title(sprintf('%d-step ahead prediction %s on Lorenz time series',...
%     horizon,upper(class(kaf))));

%% plot variance
% figure;
% hold all;
% t = (1:N)';
% z = patch([t; flipud(t)], [Y_est+Yvar_est; flipud(Y_est-Yvar_est)], 'r');
% for i=1:length(z)
%     set(z(i),'FaceAlpha',0.3);
%     set(z(i),'EdgeColor','None');
% end
% h(1) = plot(Y,'-g');
% h(2) = plot(Y_est,'-r');
% title('Variance');
% ylim([-1 1.5]);
% legend(h,{'observed','prediction'},'Location','SE');

%% load testing data
data_odd = load(files_odd);
ntrials = length(data_odd.sourceanalysis_all);

test_label = 0;

%% test data with anomalies
fprintf(1,'Running KRLS-T on anomalies...\n');

h = figure;
Y_est_mean = [];
for j=1:ntrials_test%ntrials
    
    % format trial data
    trial_struct = data_odd.sourceanalysis_all(j);
    trial_data = cell2mat(trial_struct.avg.mom(trial_struct.inside)); % channels x time
    
    % select post stim data
    idx_time = data_odd.sourceanalysis_all(j).time >= 0;
    trial_data(:,~idx_time) = [];
    
    nsamples = size(trial_data,2);
    
    % set up training labels
    Y = repmat(test_label,nsamples,1);
    
    % allocate mem
    Y_est = zeros(nsamples,1);
    Yvar_est = zeros(nsamples,1);
    
    % set up counters
    idx_end = embedding;
    
    N = nsamples-embedding+1;
    for i=1:N
        % progress indicator, 10 dots
        if ~mod(i,floor(nsamples/10))
            fprintf('.'); 
        end 
        
        % set current sample
        x = trial_data(:,i:idx_end);
        % reshape x into a vector arranged by channel
        %   [x_ch1 x_ch2 ... x_chN]
        x = reshape(x',1,numel(x));
        
        % train KRLS
        [Y_est(i), Yvar_est(i)] = kaf.evaluate(x); % predict the next output
        
        % increment counters
        idx_end = i + embedding;
    end
    if j == 1
        Y_est_mean = Y_est;
        Yvar_mean = Yvar_est;
    else
        Y_est_mean = Y_est_mean + Y_est;
        Yvar_mean = Yvar_mean + Yvar_est;
    end
    
    fprintf('\n');
    SE = (Y-Y_est).^2; % square error
    
    fprintf('Average MSE: %.2fdB\n\n',...
        10*log10(mean(SE)));
    
    figure(h); 
    
    plot(Y); 
    hold on;
    plot(Y_est);
    hold on;
    t = (1:length(Y_est))';
    z = patch([t; flipud(t)], [Y_est+Yvar_est; flipud(Y_est-Yvar_est)], 'r');
    for i=1:length(z)
        set(z(i),'FaceAlpha',0.3);
        set(z(i),'EdgeColor','None');
    end
    
    legend({'original','prediction'},'Location','SE');
    ylim([-0.5 1.5]);
    title(sprintf('%s AD on Deviant stimulus - Trial %d',...
        upper(class(kaf)),j));
    hold off;
end

Y_est_mean = Y_est_mean/ntrials_test;
Yvar_mean = Yvar_mean/(ntrials_test^2);
h1 = figure;

plot(Y,'-b'); 
hold on;
plot(Y_est_mean,'-r');
hold on;
t = (1:length(Y_est_mean))';
z = patch([t; flipud(t)], [Y_est_mean+Yvar_mean; flipud(Y_est_mean-Yvar_mean)], 'r');
for i=1:length(z)
    set(z(i),'FaceAlpha',0.3);
    set(z(i),'EdgeColor','None');
end

legend({'original','average'},'Location','SE');
ylim([-0.5 1.5]);
title(sprintf('Average %s AD on Deviant stimulus',...
    upper(class(kaf))));
hold off;

%% plot variance
% figure;
% hold all;
% t = (1:N)';
% z = patch([t; flipud(t)], [Y_est+Yvar_est; flipud(Y_est-Yvar_est)], 'r');
% for i=1:length(z)
%     set(z(i),'FaceAlpha',0.3);
%     set(z(i),'EdgeColor','None');
% end
% h = [];
% h(1) = plot(Y_test_true,'-b');
% h(2) = plot(Y_est,'-r');
% title('Variance');
% %ylim([0 2]);
% legend(h,{'truth','prediction'},'Location','SE');

