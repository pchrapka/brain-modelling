function obj = get_aal(obj,varargin)
%GET_AAL dds patches for the AAL configuration
%   GET_AAL(...) returns all the partitions of the AAL atlas
%
%   Parameters
%   ----------
%   verbosity (default = 0)
%       toggles verbosity level
%   
%   Output
%   ------
%   updates the following fields
%   name (string)
%       name of patch
%   labels (cell array of string)
%       anatomical labels that make up the patch, each patch contains a
%       mutually exclusive set of labels
%   atlasfile (string)
%       path of associated atlas file

p = inputParser;
addParameter(p,'verbosity',0);
parse(p,varargin{:});

% set up an atlas
obj.atlasfile = fullfile(ft_get_dir(),'template','atlas','aal','ROI_MNI_V4.nii');
atlas = ft_read_atlas(atlas_file);

nlabels = length(atlas.tissuelabel);

for i=1:nlabels
    obj.add_patch(ftb.PatchLabel(atlas.tissuelabel{i},{atlas.tissuelabel{i}}));
end

end