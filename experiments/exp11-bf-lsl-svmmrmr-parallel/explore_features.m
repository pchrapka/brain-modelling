%% explore_features

test = true;

if test
    labelfile = 'output/lattice-svm-test/st3fm-params-fm-test/features-matrix.mat';
    outfiles = {...
        'output/lattice-svm-test/st4fv-params-fv-100/features-validated.mat',...
        };
else
    labelfile = {...
        'output/lattice-svm/P022-9913/st3fm-params-fm-1/features-validated.mat',...
        };
    outfiles = {...
        'output/lattice-svm/P022-9913/st4fv-params-fv-20/features-validated.mat',...
        'output/lattice-svm/P022-9913/st4fv-params-fv-40/features-validated.mat',...
        'output/lattice-svm/P022-9913/st4fv-params-fv-60/features-validated.mat',...
        'output/lattice-svm/P022-9913/st4fv-params-fv-100/features-validated.mat',...
        'output/lattice-svm/P022-9913/st4fv-params-fv-1000/features-validated.mat',...
        'output/lattice-svm/P022-9913/st4fv-params-fv-2000/features-validated.mat',...
        };
end

din2 = load(labelfile);
labels = din2.data.feature_labels;

for i=1:length(outfiles)
    fprintf('file: %s\n',outfiles{i});
    
    % load data
    din = load(outfiles{i});
    
    % select common features
    ncommon = 10;
    [feat_common, freq] = features_select_common(din.data.feat_sel,ncommon);
    
    % select corresponding labels
    labels_mrmr = labels(feat_common);
    
    fprintf(' Index     | Frequency | Label     \n');
    fprintf('-----------------------------------\n');
    for j=1:ncommon
        fprintf(' %9d | %9d | %s\n',feat_common(j), freq(j), labels_mrmr{j});
    end
    
end