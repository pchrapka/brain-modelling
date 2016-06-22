function ratio = fishers_discriminant_ratio(features, class_labels)
%   features (matrix)
%       matrix containing features arranged as [samples features]
%   class_labels (vector)
%       class label, we assume there are only two classes

% get unique class labels
labels = unique(class_labels);
nlabels = length(labels);

% check number of labels
if nlabels ~= 2
    error([mfilename ':params'],...
        'requires 2 unique class labels');
end

% allocate mem
nfeatures = size(features,2);
mu = zeros(nlabels,nfeatures);
sigma = zeros(nlabels,nfeatures);

% loop through lables
for i=1:nlabels
    % get sample index for current label
    idx = (class_labels == labels(i));

    % calculate mean and std
    mu(i,:) = mean(features(idx,:));
    sigma(i,:) = std(features(idx,:));
end

ratio = (mu(1,:) - mu(2,:)).^2./(sigma(1,:).^2 + sigma(2,:).^2);
if ~isequal(size(ratio),[1 nfeatures])
    error([mfilename ':output'],...
        'something went wrong here');
end

end