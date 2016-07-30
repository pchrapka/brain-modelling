function patches = get_aal(varargin)
%GET_AAL returns anatomical labels partitioned into patches
%   GET_AAL(...) returns all the partitions of the AAL atlas
%
%   Parameters
%   ----------
%   verbosity (default = 0)
%       toggles verbosity level
%   
%   Output
%   ------
%   patches (struct array)
%       struct describing each patch
%   patches.name (string)
%       name of patch
%   patches.labels (cell array of string)
%       anatomical labels that make up the patch, each patch contains a
%       mutually exclusive set of labels
%   patches.atlasfile (string)
%       path of associated atlas file

p = inputParser;
addParameter(p,'verbosity',0);
parse(p,varargin{:});

% set up an atlas
atlas_file = fullfile(ft_get_dir(),'template','atlas','aal','ROI_MNI_V4.nii');
atlas = ft_read_atlas(atlas_file);

nlabels = length(atlas.tissuelabel);

% set up patches struct array
patches = [];
patches(nlabels).name = '';

% copy all tissue labels
[patches.name] = deal(atlas.tissuelabel{:});
[patches.labels] = patches.name;
[patches.atlasfile] = deal(atlas_file);

end