function plot_anatomical(obj,varargin)
%PLOT_ANATOMICAL plots source power on anatomical image
%   PLOT_ANATOMICAL(obj, ['method', value, 'options', value]) plots source
%   power on anatomical images. Method can be 'slice' or 'ortho'.
%
%   method (default = 'slice')
%       plotting method: slice or ortho
%   options (struct)
%       options for ft_sourceplot, see ft_sourceplot
%   mask (default = 'none')
%       mask for functional data, if using this opt
%       max - plots values above 50% of maximum
%       none - no mask

% parse inputs
p = inputParser;
p.StructExpand = false;
addParameter(p,'method','slice',@(x)any(validatestring(x,{'slice','ortho'})));
addParameter(p,'options',[]);
addParameter(p,'mask','none',@(x)any(validatestring(x,{'max','none'})));
parse(p,varargin{:});

% load source analysis
source = ftb.util.loadvar(obj.sourceanalysis);

% get MRI object
mriObj = obj.get_dep('ftb.MRI');

% reslice
% TODO save instead of redoing
cfgin = [];
mri = ftb.util.loadvar(mriObj.mri_mat);
resliced = ft_volumereslice(cfgin, mri);

if isfield(source,'time')
    source = rmfield(source,'time');
end

% interpolate
cfgin = [];
cfgin.parameter = 'pow';
interp = ft_sourceinterpolate(cfgin, source, resliced);

% data transformation
plot_log = false;
if plot_log
    interp.pow = db(interp.pow,'power');
end

% source plot
cfgplot = [];
if ~isempty(p.Results.options)
    % copy options
    cfgplot = copyfields(p.Results.options, cfgplot, fieldnames(p.Results.options));
end

if isfield(cfgplot,'mask') && ~isempty(p.Results.mask)
    warning('overwriting mask field');
end
switch p.Results.mask
    case 'max'
        fprintf('creating mask\n');
        cfgplot.maskparameter = 'mask';
        interp.mask = interp.pow > max(interp.pow(:))*0.3; % 50% of maximum
    case 'none'
        % none
end

cfgplot.method = p.Results.method;
cfgplot.funparameter = 'pow';
ft_sourceplot(cfgplot, interp);

end