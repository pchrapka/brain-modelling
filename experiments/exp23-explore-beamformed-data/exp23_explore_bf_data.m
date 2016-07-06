%% exp23_explore_bf_data
% plots patch time series for each trial

% data_file = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat';
data_file = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat';

data = loadfile(data_file);

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

overlay_variance = true;

if overlay_variance
    % take mean and var
    sources_mean = squeeze(mean(sources,1));
    sources_var = squeeze(var(sources,1));
end

ymax = sources_mean + 2*sqrt(sources_var);
for i=1:length(size(sources_mean))
    ymax = max(ymax);
end
ymin = -ymax;

%% plot
for j=1:length(data)
    [ntrial,nsources,ntime] = size(sources);
    ncols = 1;
    nrows = nsources;
    
    %clear figure
    clf;
    
    for i=1:nsources
        subaxis(nrows, ncols, i,...
            'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
        
        if overlay_variance
            h = plot_mean_and_var(1:ntime, sources_mean(i,:), sources_var(i,:),'b');
            for k=1:length(h)
                set(h(k),'FaceAlpha',0.3);
                set(h(k),'EdgeColor','None');
            end
            hold on;
        end
    
        plot(squeeze(sources(j,i,:)));
        set(gca,'xticklabel',[]);
        xlim([1 ntime]);
        ylim([ymin ymax]);
        
        hold off;
    end
    
    prompt = 'Press any key to show next trial, q to exit?';
    response = input(prompt,'s');
    switch response
        case 'q'
            close;
            break;
    end
end