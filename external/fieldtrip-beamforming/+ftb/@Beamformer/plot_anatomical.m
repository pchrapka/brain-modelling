function plot_anatomical(obj,varargin)
%PLOT_ANATOMICAL plots source power on anatomical image
%   PLOT_ANATOMICAL(obj, [method]) plots source power on anatomical images.
%   Method can be 'slice' or 'ortho'.

% parse inputs
p = inputParser;
p.StructExpand = false;
addParameter(p,'method','slice',@(x)any(validatestring(x,{'slice','ortho'})));
parse(p,varargin{:});

% load source analysis
source = ftb.util.loadvar(obj.sourceanalysis);

% get MRI object
mriObj = obj.get_dep('ftb.MRI');

cfgin = [];
mri = ftb.util.loadvar(mriObj.mri_mat);
resliced = ft_volumereslice(cfgin, mri);

% Take neural activity index
% NOTE doesn't seem to help
sourcenai = source;
% if exist('source_noise', 'var')
%     sourcenai.avg.pow = source.avg.pow ./ source_noise.avg.pow - 1;
% end
% %sourcenai.avg.pow = source.avg.pow ./ source.avg.noise;

cfgin = [];
cfgin.parameter = 'pow';
interp = ft_sourceinterpolate(cfgin, sourcenai, resliced);

plot_log = false;
if plot_log
    interp.pow = db(interp.pow,'power');
end

cfgin = [];
cfgin.method = p.Results.method;
cfgin.funparameter = 'pow';
ft_sourceplot(cfgin, interp);

end