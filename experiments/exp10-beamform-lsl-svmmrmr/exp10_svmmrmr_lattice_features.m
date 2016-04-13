%% exp10_svmmrmr_lattice_features
% Goal: 
%   Summarize reflection coefficient time series. There are way too many
%   raw coefficients (400k) for feature selection to run in a reasonable
%   amount of time

% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));
lattice_folder = fullfile(srcdir,'output','lattice');

%% load data
files = dir(fullfile(lattice_folder,'lattice*.mat'));

% get dimensions
nsamples = length(files);
din = load(fullfile(lattice_folder,files(1).name));
nfeatures = numel(din.lattice.Kf);

% allocate mem
samples = zeros(nsamples, nfeatures);
class_labels = zeros(nsamples,1);
bad_samples = false(nsamples,1);
features = [];

% params
thresh = 2;
feat_names = {'hist','mean','std','var',...
    'harmmean','trimmean','kurtosis','skewness'};
% set feature options
feat_options = cell(length(feat_names),1);
% initialize each cell with an empty cell
[feat_options{:}] = deal({});
feat_options{1} = {linspace(-1.5,1.5,20)};

% loop over data files
for i=1:nsamples
    fprintf('sample %d\n',i);
    din = load(fullfile(lattice_folder,files(i).name));
    
    % get label
    switch din.lattice.label
        case 'std'
            class_labels(i) = 1;
        case 'odd'
            class_labels(i) = 0;
    end
    
    % check if we have bad samples
    samples = reshape(din.lattice.Kf,1,nfeatures);
    if any(abs(samples) > thresh)
        bad_samples(i,1) = true;
    end
    
    % compute features
    lf = LatticeFeatures(din.lattice.Kf);
    % add features
    for j=1:length(feat_names)
        fprintf('\tfeature: %s\n',feat_names{j});
        options = feat_options{j};
        lf.add(feat_names{j},options{:});
    end
    
    % collect features
    if i==1
        features = zeros(nsamples,length(lf.features));
        feature_labels = lf.labels;
    end
    features(i,:) = lf.features'; %#ok<SAGROW>
end

% remove bad samples
features(bad_samples,:) = [];
class_labels(bad_samples,:) = [];

%% normalize features
% TODO double check if i should zero mean the features
nsamples = size(features,1);
features_zeromean = features - repmat(mean(features),nsamples,1);
features_norm = features_zeromean./repmat(std(features_zeromean,0,1),nsamples,1);

%% validate features
model = SVMMRMR(features_norm, class_labels, 'implementation', 'libsvm'); %, feature_labels);
nfeatures = 100;
nbins = 20;
[predictions, feat_sel] = model.validate_features(...
    'nfeatures',nfeatures,'nbins',nbins,'verbosity',1);
% TODO expand grid search

%% plot confusion matrix
[confusion_mat, confusion_order] = confusionmat(class_labels, predictions);

heatmap(confusion_mat, confusion_order, confusion_order, 1,...
    'Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);

%% common features
[feat_common, freq] = features_select_common(feat_sel, 100);

%% save
data = [];
data.nbins = nbins;
data.nfeatures = nfeatures;
data.feat_sel = feat_sel;
data.feature_labels = feature_labels;
data.predictions = predictions;
file_out = fullfile(srcdir,'output',[strrep(mfilename,'_','-') '-' datestr(now,'yyyy-mm-dd') '.mat']);
save(file_out,'data');
