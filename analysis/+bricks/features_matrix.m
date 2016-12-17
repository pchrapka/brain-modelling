function features_matrix(files_in,files_out,opt)
%FEATURES_MATRIX creates feature matrix from samples
%   FEATURES_MATRIX creates feature matrix from samples. formatted
%   for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (string/cell/struct)
%       file name(s) of samples file(s) to process, see output of
%       bricks.lattice_filter_sources
%       
%       struct version
%       contains fields test and train each containing a file name of a
%       list of samples to process, requires the file_in_field parameter
%   files_out (string)
%       output file name
%   opt (cell array)
%       function options specified as name value pairs. unmatched name
%       value pairs are passed onto the data2feature function
%   
%   Parameters
%   ----------
%   data2feature (string)
%       function name that converts a list of data files to a feature
%       matrix
%
%       [samples,class_labels,feature_labels] = data2feature(file_list); 
%
%   file_in_field (string, default = '')
%       name of the field in files_in to select as the input file for the
%       function
%
%   DEPRECATED? threshold (scalar, default = 'none')
%       threshold for lattice coefficient values, samples containing
%       coefficents above this value are removed
%
%   Output
%   ------
%   output data contains the following fields
% 
%   feature_labels (cell array) 
%       feature labels
%   samples (matrix)
%       feature matrix with size [samples features]
%   class_labels (vector)
%       class labels for each sample

p = inputParser;
p.KeepUnmatched = true;
p.StructExpand = false;
addRequired(p,'files_in',@(x) ischar(x) | isstruct(x) | iscell(x));
addRequired(p,'files_out',@ischar);
addParameter(p,'data2feature',@ischar);
addParameter(p,'file_in_field','',@ischar);
parse(p,files_in,files_out,opt{:});

if ~isparfor()
    % fail if parallel execution isn't set up
    return;
end

% load the file list
if isstruct(files_in)
    if isempty(p.Results.file_in_field)
        error('file_in_field parameter is required');
    end
    file_list = files_in.(p.Results.file_in_field);
else
    file_list = files_in;
end

% convert data
fh = str2func(p.Results.data2feature);
opt_fh = struct2namevalue(p.Unmatched);
[samples,class_labels,feature_labels] = fh(file_list,opt_fh{:});

% save data
data = [];
data.feature_labels = feature_labels;
data.samples = samples;
data.class_labels = class_labels;
save(files_out, 'data','-v7.3');

end