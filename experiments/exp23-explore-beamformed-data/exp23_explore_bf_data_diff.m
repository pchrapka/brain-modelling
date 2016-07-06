%% exp23_explore_bf_data_diff
% plots difference in mean of patch time series between std and odd conditions

% clear all;
% close all;

% data_source = 'all-trials';
data_source = 'consecutive-trials';

data_file = {};
switch data_source
    case 'all-trials'
        data_file{1} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat';
        data_file{2} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat';
    case 'consecutive-trials'
        data_file{1} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstdconsec-BPatchTriallcmvmom/sourceanalysis.mat';
        data_file{2} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGoddconsec-BPatchTriallcmvmom/sourceanalysis.mat';
end

%% get data
result = cell(length(data_file),1);
for k=1:length(data_file)
    % load data
    data = loadfile(data_file{k});
    
    ntrials = length(data);
    % load one trial for memory allocation
    temp = data(1).avg.mom(data(1).inside);
    % convert to matrix [patches x time]
    sources_temp = cell2mat(temp);
    result{k}.sources = zeros([ntrials size(sources_temp)]);
    
    % extract all data
    for j=1:length(data)
        % get source data
        temp = data(j).avg.mom(data(j).inside);
        % convert to matrix [patches x time]
        result{k}.sources(j,:,:) = cell2mat(temp);
    end
    
    % take mean and var
    result{k}.sources_mean = squeeze(mean(result{k}.sources,1));
    result{k}.sources_var = squeeze(var(result{k}.sources,1));
    
end

%% take diff
sources_mean_diff = result{1}.sources_mean - result{2}.sources_mean;
sources_var_diff = result{1}.sources_var + result{2}.sources_var;

%% plot

[ntrials,nsources,ntime] = size(result{1}.sources);
ncols = 1;
nrows = nsources;
figure;
for k=1:2
    for i=1:nsources
        subaxis(nrows, ncols, i,...
            'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
        
        hold on;
        plot(result{k}.sources_mean(i,:));
        
        set(gca,'xticklabel',[]);
        xlim([1 ntime]);
        
        if i==1 && k==1
            title('Averaged std and odd');
        end
    end
end

figure;
for i=1:nsources
    subaxis(nrows, ncols, i,...
        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
    
    plot(sources_mean_diff(i,:),'-b');
    
    set(gca,'xticklabel',[]);
    xlim([1 ntime]);
    
    if i==1
        title('MMN');
    end
end