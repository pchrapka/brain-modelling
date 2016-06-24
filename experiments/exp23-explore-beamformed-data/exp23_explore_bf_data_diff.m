%% exp23_explore_bf_data_diff

data_file = {};
data_file{1} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat';
data_file{2} = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat';

%% get data
result = cell(length(data_file),1);
for k=1:length(data_file)
    % load data
    data = ftb.util.loadvar(data_file{k});
    
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
    result{k}.sources_mean = squeeze(mean(sources,1));
    result{k}.sources_var = squeeze(var(sources,1));
    
end

%% take diff
sources_mean_diff = result{1}.sources_mean - result{2}.sources_mean;
sources_var_diff = result{1}.sources_var + result{2}.sources_var;

overlay_variance = false;

%% plot
[ntrials,nsources,ntime] = size(sources);
ncols = 1;
nrows = nsources;
for i=1:nsources
    subaxis(nrows, ncols, i,...
        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
    
    if overlay_variance
        h = plot_mean_and_var(1:ntime, sources_mean_diff(i,:), sources_var_diff(i,:),'b');
        for j=1:length(h)
            set(h(j),'FaceAlpha',0.3);
            set(h(j),'EdgeColor','None');
        end
        hold on;
    end
    plot(sources_mean_diff(i,:),'-b');
    
    set(gca,'xticklabel',[]);
    xlim([1 ntime]);
end