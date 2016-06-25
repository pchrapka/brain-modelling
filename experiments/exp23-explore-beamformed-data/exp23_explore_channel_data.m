%% exp23_explore_channel_data

data_file = {};
data_file{1} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd/timelock.mat';
data_file{2} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd/timelock.mat';

result = cell(length(data_file),1);
for i=1:length(data_file)

    % load data
    data = ftb.util.loadvar(data_file{i});
    
    result{i}.trial_mean = data.avg;
    result{i}.label = data.label;

end

%% take diff
trial_mean_diff = result{1}.trial_mean - result{2}.trial_mean;
% sources_var_diff = result{1}.sources_var + result{2}.sources_var;

%% plot

[ntrials,nchannels,ntime] = size(result{1}.trials);
ncols = 1;
nrows = nchannels;
figure;
for k=1:length(result)
    for i=1:nchannels
        subaxis(nrows, ncols, i,...
            'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
        
        hold on;
        plot(result{k}.trial_mean(i,:));
        ylabel(result{k}.label(i));
        
        set(gca,'xticklabel',[]);
        xlim([1 ntime]);
    end
end

figure;
for i=1:nchannels
    subaxis(nrows, ncols, i,...
        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
    
    plot(trial_mean_diff(i,:),'-b');
    ylabel(result{k}.label(i));
    
    set(gca,'xticklabel',[]);
    xlim([1 ntime]);
end