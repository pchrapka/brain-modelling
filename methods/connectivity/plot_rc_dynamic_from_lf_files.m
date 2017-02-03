function plot_rc_dynamic_from_lf_files(files,varargin)
%PLOT_RC_DYNAMIC_FROM_LF_FILES plots dynamic RC of lattice filtered data
%   PLOT_RC_DYNAMIC_FROM_LF_FILES(files,...) plots dynamic RC of lattice
%   filtered data
%
%   Input
%   -----
%   files (cell array/string)
%       file names of data after lattice filtering
%
%   Parameters
%   ----------
%   outdir (string, default = pwd)
%       output directory
%   save (logical, default = false)
%       flag to save figure
%   mode (string, default = 'tiled')
%       plot mode: tiled, summary

p = inputParser();
addRequired(p,'files',@(x) ischar(x) || iscell(x))
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
options_mode = {'tiled','summary'};
addParameter(p,'mode','tiled',@(x) any(validatestring(x,options_mode)));
parse(p,files,varargin{:});

if ischar(p.Results.files)
    files = {p.Results.files};
end

if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

for i=1:length(files)
    
    % load
    data = loadfile(files{i});
    [~,name,~] = fileparts(files{i});
    
    % plot
    h = figure;
    set(h,'NumberTitle','off','MenuBar','none', 'Name', name );
    set(h, 'Position', [50, 50, 1100, 900]);
    switch p.Results.mode
        case 'tiled'
            plot_rc_dynamic(data.estimate.Kf);
        case 'summary'
            plot_rc_dynamic_summary(data.estimate.Kf);
        otherwise
            error('unknown mode %s',p.Results.mode);
    end
    
    if p.Results.save
        % save
        save_fig_exp(outdir,'tag', [name '-rc-dynamic']);
    end
    
end

end