function add_label(files_in,files_out,opt)
%ADD_LABEL adds a label to the data
%   ADD_LABEL adds a label to the data. formatted for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (string)
%       file name of sourceanalysis file processed by ftb.BeamformerPatchTrial
%   files_out (string)
%       file name of modified source analysis
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   label (string)
%       label for data

p = inputParser;
p.StructExpand = false;
addRequired(p,'files_in',@ischar);
addRequired(p,'files_out',@ischar);
addParameter(p,'label',@(x) ~isempty(x) && ischar(x));
parse(p,files_in,files_out,opt{:});

% load data
data = loadfile(files_in);
% add label
[data.label] = deal(p.Results.label);

save(files_out,'data');

end