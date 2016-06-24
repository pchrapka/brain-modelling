%% exp23_explore_bf_data_mean

% data_file = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat';
data_file = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat';

% load data
data = ftb.util.loadvar(data_file);

ntrials = length(data);
% load one trial for memory allocation
temp = data(1).avg.mom(data(1).inside);
% convert to matrix [patches x time]
sources_temp = cell2mat(temp);
sources = zeros([ntrials size(sources_temp)]);

% extract all data
for j=1:length(data)
    % get source data
    temp = data(j).avg.mom(data(j).inside);
    % convert to matrix [patches x time]
    sources(j,:,:) = cell2mat(temp);
end

% take mean and var
sources_mean = squeeze(mean(sources,1));
sources_var = squeeze(var(sources,1));

% plot
[ntrials,nsources,ntime] = size(sources);
ncols = 1;
nrows = nsources;
for i=1:nsources
    subaxis(nrows, ncols, i,...
        'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
    
    h = plot_mean_and_var(1:ntime, sources_mean(i,:), sources_var(i,:),'b');
    for j=1:length(h)
        set(h(j),'FaceAlpha',0.3);
        set(h(j),'EdgeColor','None');
    end
    hold on;
    plot(sources_mean(i,:),'-b');
    
    set(gca,'xticklabel',[]);
    xlim([1 ntime]);
end