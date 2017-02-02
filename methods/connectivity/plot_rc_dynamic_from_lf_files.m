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

p = inputParser();
addRequired(p,'files',@(x) ischar(x) || iscell(x))
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
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
    plot_rc_dynamic(data.estimate.Kf);
    
    if p.Results.save
        % save
        save_fig_exp(outdir,'tag', [name '-rc-dynamic']);
    end
    
end

end