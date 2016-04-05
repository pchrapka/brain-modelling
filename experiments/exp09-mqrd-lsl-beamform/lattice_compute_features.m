function [features, labels] = lattice_compute_features(data)
%
%   data (matrix)
%       reflection coefficient matrix, [samples order channels channels]
%
%   features (vector)
%       vector of features

features = [];

feature_names = {'hist','mean','std','var'};
for i=1:length(feature_names)
    switch feature_names{i}
        case 'hist'
            
        case 'mean'
        case 'std'
        case 'var'
        otherwise
            error('feature not implemented');
    end
end

end