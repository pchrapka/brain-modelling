function features_validate(files_in,files_out,opt)
%FEATURES_VALIDATE validates features using the SVMMRMR class
%   FEATURES_VALIDATE validates features using the SVMMRMR class. formatted
%   for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (string)
%       file containing feature matrx, see also
%       bricks.lattice_features_matrix
%   files_out (string)
%       file containing validated features
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   see SVMMRMR.validate_features
%
%   nfeatures (integer, default = 10)
%       number of features to select during mRMR step
%   nbins (integer, default = 10)
%       number of bins to use for the discretization
%
%       NOTE for feature selection 10 bins is a good choice
%       (Brown2012, "Conditional Likelihood Maximisation: A
%       Unifying Framework for Information Theoretic Feature
%       Selection")
%
%   verbosity (integer, default = 0)
%       verbosity level of function, choices 0,1,2


p = inputParser;
p.KeepUnmatched = true;
addRequired(p,'files_in',@ischar);
addRequired(p,'files_out',@ischar);
parse(p,files_in,files_out,opt{:});

% load the data
data_in = loadfile(files_in);

% create a model
model = SVMMRMR(data_in.features, data_in.class_labels, 'implementation', 'libsvm');

% validate features
data = [];
[data.predictions, data.feat_sel] = model.validate_features(opt{:});
data.class_labels = data_in.class_labels;

% save output
save(files_out,'data','-v7.3');

end