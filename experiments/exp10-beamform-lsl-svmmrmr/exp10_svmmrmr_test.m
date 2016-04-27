%% exp10_svmmrmr_test

nsamples = 10;
nfeatures = 100;
features = randn(nsamples,nfeatures);
nclass1 = nsamples/2;
class_labels = [ones(nclass1,1); zeros(nsamples-nclass1,1)];

%% normalize features
% TODO double check if i should zero mean the features
features_zeromean = features - repmat(mean(features),nsamples,1);
features_norm = features_zeromean./repmat(std(features_zeromean,0,1),nsamples,1);

%% validate features
model = SVMMRMR(features_norm, class_labels, 'implementation', 'libsvm'); %, feature_labels);
nfeatures = 10;
nbins = 20;
[predictions, feat_sel] = model.validate_features(...
    'nfeatures',nfeatures,'nbins',nbins,'verbosity',2);