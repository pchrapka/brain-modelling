%% exp23_explore_bf_data

% data_file = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat';
data_file = '../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat';

data = ftb.util.loadvar(data_file);

% ntrials = 1;
% trial_idx = randsample(1:length(data),ntrials);

for j=1:length(data)
    % get source data
    temp = data(j).avg.mom(data(j).inside);
    % convert to matrix [patches x time]
    sources = cell2mat(temp);
    
    [nsources,ntime] = size(sources);
    ncols = 1;
    nrows = nsources;
    for i=1:nsources
        subaxis(nrows, ncols, i,...
            'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.05);
        plot(sources(i,:));
        set(gca,'xticklabel',[]);
        xlim([1 ntime]);
    end
    
    prompt = 'Press any key to show next trial, q to exit?';
    response = input(prompt,'s');
    switch response
        case 'q'
            break;
    end
end