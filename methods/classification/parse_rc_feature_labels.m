function [time,order,channel1,channel2] = parse_rc_feature_labels(labels)

nfeatures = length(labels);

% parse feature labels
time = zeros(nfeatures,1);
order = zeros(nfeatures,1);
channel1 = zeros(nfeatures,1);
channel2 = zeros(nfeatures,1);
for i=1:nfeatures
    % figure out number of time points, filter orders, and channels
    pattern = 't(\d+)-p(\d+)-c(\d+)-c(\d+)';
    results = regexp(labels{i}, pattern, 'tokens');
    
    time(i) = str2double(results{1}{1});
    order(i) = str2double(results{1}{2});
    channel1(i) = results{1}{3};
    channel2(i) = results{1}{4};
end

end