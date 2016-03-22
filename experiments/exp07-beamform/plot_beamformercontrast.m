function plot_beamformercontrast(bf_contrast, varargin)
%PLOT_BEAMFORMERCONTRAST plots BeamformerContrast object 
%   PLOT_BEAMFORMERCONTRAST(bf_contrast, [name, value]) plots BeamformerContrast
%   object
%
%   Input
%   -----
%   bf_contrast (BeamformerContrast object)
%       BeamformerContrast object
%
%   Parameter options
%   beamformer (boolean)
%       plots beamformer data
%   moment (boolean)
%       plots moment data
%   save (boolean)
%       flag for saving images

% parse inputs
p = inputParser;
p.StructExpand = false;
addParameter(p,'beamformer',false,@islogical);
addParameter(p,'moment',false,@islogical);
addParameter(p,'save',false,@islogical);
parse(p,varargin{:});

%% Beamformer plots

if p.Results.save
    cfgsave = [];
    [pathstr,~,~] = fileparts(bf_contrast.sourceanalysis);
    cfgsave.out_dir = fullfile(pathstr,'img');
    
    if ~exist(cfgsave.out_dir,'dir')
        mkdir(cfgsave.out_dir);
    end
end

if p.Results.beamformer
    % figure;
    % bf.plot({'brain','skull','scalp','fiducials'});
    
    options = [];
    %options.funcolorlim = [-0.2 0.2];
    options.funcolormap = 'jet';
    
    %figure;
    %bf_contrast.plot_scatter([]);
    bf_contrast.plot_anatomical('method','slice','options',options);
    save_fig(cfgsave, 'full-slice-contrast-no-mask', p.Results.save);
    bf_contrast.plot_anatomical('method','ortho','options',options);
    save_fig(cfgsave, 'full-ortho-contrast-no-mask', p.Results.save);
    bf_contrast.plot_anatomical('method','slice','options',options,'mask','max');
    save_fig(cfgsave, 'full-slice-contrast-mask', p.Results.save);
    bf_contrast.plot_anatomical('method','ortho','options',options,'mask','max');
    save_fig(cfgsave, 'full-ortho-contrast-mask', p.Results.save);
    
    if p.Results.moment
        figure;
        bf_contrast.plot_moment('2d-all');
        figure;
        bf_contrast.plot_moment('2d-top');
        figure;
        bf_contrast.plot_moment('1d-top');
    end
    
    options = [];
    %options.funcolorlim = [-0.2 0.2];
    options.funcolormap = 'jet';
    
    %figure;
    %bf_contrast.pre.plot_scatter([]);
    bf_contrast.pre.plot_anatomical('method','slice','options',options);
    save_fig(cfgsave, 'pre-slice-contrast-no-mask', p.Results.save);
    bf_contrast.pre.plot_anatomical('method','ortho','options',options);
    save_fig(cfgsave, 'pre-ortho-contrast-no-mask', p.Results.save);
    
    if p.Results.moment
        figure;
        bf_contrast.pre.plot_moment('2d-all');
        figure;
        bf_contrast.pre.plot_moment('2d-top');
        figure;
        bf_contrast.pre.plot_moment('1d-top');
    end
    
    %figure;
    %bf_contrast.post.plot_scatter([]);
    bf_contrast.post.plot_anatomical('method','slice','options',options);
    save_fig(cfgsave, 'post-slice-contrast-no-mask', p.Results.save);
    bf_contrast.post.plot_anatomical('method','ortho','options',options);
    save_fig(cfgsave, 'post-ortho-contrast-no-mask', p.Results.save);
    
    if p.Results.moment
        figure;
        bf_contrast.post.plot_moment('2d-all');
        figure;
        bf_contrast.post.plot_moment('2d-top');
        figure;
        bf_contrast.post.plot_moment('1d-top');
    end
end
end