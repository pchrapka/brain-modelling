function plot_anatomical(obj,varargin)
%PLOT_ANATOMICAL plots source power on anatomical image
%   PLOT_ANATOMICAL(obj, ['method', value, 'options', value]) plots source
%   power on anatomical images. Method can be 'slice' or 'ortho'.
%
%   Parameters
%   ----------
%   method (default = 'slice')
%       plotting method: slice or ortho
%   options (struct)
%       options for ft_sourceplot, see ft_sourceplot
%   mask (default = 'none')
%       mask for functional data, if using this opt
%       max - plots values above 50% of maximum
%       none - no mask

% get MRI object
mriObj = obj.get_dep('ftb.MRI');
% load data
mri = ftb.util.loadvar(mriObj.mri_mat);
source = ftb.util.loadvar(obj.sourceanalysis);

obj.plot_anatomical_deps(mri,source,varargin{:});
end