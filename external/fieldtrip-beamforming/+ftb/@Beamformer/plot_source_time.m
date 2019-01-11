function plot_source_time(obj,mode,varargin)
%PLOT_ANATOMICAL_TIME plots source power on anatomical image
%   PLOT_ANATOMICAL_TIME(obj, ['method', value, 'options', value]) plots source
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

if strcmp(mode, 'anatomical')
    % get MRI object
    mriObj = obj.get_dep('ftb.MRI');
    % load data
    mri = ftb.util.loadvar(mriObj.mri_mat);
    cfgin = [];
    resliced = ft_volumereslice(cfgin, mri);
end
source = ftb.util.loadvar(obj.sourceanalysis);

idx_time = 1;
cfg_ft_selectdata = [];
cfg_ft_selectdata.latency = source.time(idx_time);

for i=1:length(source.time)
    switch mode
        case 'anatomical'
            obj.plot_anatomical_deps(mri,source,...
                'mri_resliced',resliced,...
                'ft_selectdata',cfg_ft_selectdata, varargin{:});
        case 'scatter'
            cfg = varargin{1};
            cfg.ft_selectdata = cfg_ft_selectdata;
            obj.plot_scatter(cfg);
        otherwise
            error('unknown mode %s',mode);
    end
    idx_time = idx_time + 1;
    
    fprintf('Time: %fs ', cfg_ft_selectdata.latency);
    user_input = input('Press any key for next, q to quit', 's');
    switch lower(user_input)
        case 'q'
            break;
        otherwise
            % update time index
            cfg_ft_selectdata.latency = source.time(idx_time);
    end
    close(gcf);
end

end