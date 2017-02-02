function plot_pdc_dynamic_from_lf_files(files,varargin)
%PLOT_PDC_DYNAMIC_FROM_LF_FILES plots dynamic PDC of lattice filtered data
%   PLOT_PDC_DYNAMIC_FROM_LF_FILES(files,...) plots dynamic PDC of lattice
%   filtered data. It also saves the conversion from RC to PDC in the same
%   directory as the filtered data.
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
    fresh = false;
    data_time = get_timestamp(files{i});
    
    % create pdc output file name
    [path,name,~] = fileparts(files{i});
    outfile_pdc = fullfile(path,sprintf('%s-pdc-dynamic.mat',name));
    fprintf('plotting pdc for %s\n',name);
    
    % check freshness
    if exist(outfile_pdc,'file')
        pdc_time = get_timestamp(outfile_pdc);
        if data_time > pdc_time
            fresh = true;
        end
    end
    
    % convert to pdc
    if fresh || ~exist(outfile_pdc,'file')
        data = loadfile(files{i});
        
        % convert to pdc
        result = rc2pdc_dynamic(data.estimate.Kf,data.estimate.Kb,'metric','euc');
        save_parfor(outfile_pdc,result);
    else
        result = loadfile(outfile_pdc);
    end
    
    % plot
    h = figure;
    set(h,'NumberTitle','off','MenuBar','none', 'Name', files{i} );
    plot_pdc_dynamic(result);
    
    if p.Results.save
        % save
        save_fig_exp(outdir,'tag', [name '-rc-dynamic']);
    end
    
end

end