%% exp09_svmmrmr_raw_fdr

% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));
lattice_folder = fullfile(srcdir,'..','lattice');

%% load data
files = dir(fullfile(lattice_folder,'lattice*.mat'));

% get dimensions
nsamples = length(files);
din = load(fullfile(lattice_folder,files(1).name));
nfeatures = numel(din.lattice.Kf);

% allocate mem
samples = zeros(nsamples, nfeatures);
class_labels = zeros(nsamples,1);
bad_samples = [];
thresh = 1.5;

% loop over data files
for i=1:nsamples
    din = load(fullfile(lattice_folder,files(i).name));
    samples(i,:) = reshape(din.lattice.Kf,1,nfeatures);
    switch din.lattice.label
        case 'std'
            class_labels(i) = 1;
        case 'odd'
            class_labels(i) = 0;
    end
    
    % check if we have bad samples
    if any(abs(samples(i,:)) > thresh)
        bad_samples(end+1,1) = i;
    end
end

% remove bad samples
samples(bad_samples,:) = [];
class_labels(bad_samples,:) = [];

% get feature labels
feature_labels = lattice_feature_labels(size(din.lattice.Kf));
feature_labels = reshape(feature_labels,1,numel(din.lattice.Kf));

ratio = fishers_discriminant_ratio(samples,class_labels);

% % check features
% figure;
% imagesc(samples);
% colorbar
% 
% figure;
% large_samples = zeros(size(samples));
% large_samples(abs(samples) > 1) = 1;
% imagesc(large_samples);

%% validate features
model = SVMMRMR(samples, class_labels); %, feature_labels);
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
[feat_common, freq] = features_select_common(feat_sel, 40);

%% save
data = [];
data.nbins = nbins;
data.nfeatures = nfeatures;
data.feat_sel = feat_sel;
data.predictions = predictions;
file_out = fullfile(srcdir,[strrep(mfilename,'_','-') '-' datestr(now,'yyyy-mm-dd') '.mat']);
save(file_out,'data');