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
%       'data' - same directory where data is located
%       somepath - any regular path
%   save (logical, default = false)
%       flag to save figure
%   mode (string, default = 'tiled')
%       plot mode: tiled, summary
%       summary is useful when a large number of channels are involved
%   params (cell array)
%       additional arguments and name value parameters for plot function

p = inputParser();
addRequired(p,'files',@(x) ischar(x) || iscell(x))
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
options_mode = {'tiled','summary','single','single-largest'};
addParameter(p,'mode','tiled',@(x) any(validatestring(x,options_mode)));
addParameter(p,'params',{},@iscell);
parse(p,files,varargin{:});

if ischar(p.Results.files)
    files = {p.Results.files};
end

usedatadir = false;
if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
elseif isequal(p.Results.outdir,'data');
    usedatadir = true;
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

for i=1:length(files)
    % set up save params
    [data_path,name,~] = fileparts(files{i});
    flag_save = p.Results.save;
    if usedatadir
        outdir = data_path;
    end
    
    print_msg_filename(files{i},'loading');
    result = loadfile(files{i});
    
    % plot
    h = figure;
    colormap('jet');
    set(h,'NumberTitle','off','MenuBar','none', 'Name', files{i} );
    fprintf('plotting pdc for %s\n',name);
    
    switch p.Results.mode
        case 'tiled'
            plot_pdc_dynamic(result,p.Results.params{:});
            save_tag = '-pdc-dynamic';
        case 'summary'
            plot_pdc_dynamic_summary(result,p.Results.params{:});
            save_tag = '-pdc-dynamic-summary';
        case 'single'
            plot_pdc_dynamic_single(result,p.Results.params{:});
            save_tag = sprintf('-pdc-dynamic-single-j%d-i%d',...
                p.Results.params{1},p.Results.params{2});
        case 'single-largest'
            p2 = inputParser();
            p2.KeepUnmatched = true;
            addParameter(p2,'nplots',5,@isnumeric);
            parse(p2,p.Results.params{:});
            
            % summarize data
            [mag,idxj,idxi] = pdc_get_summary(result);
            % sort in descending
            [~,idx_sorted] = sortrows(mag,-1);
            
            % plot single and save each
            for j=1:p2.Results.nplots
                idxj_cur = idxj(idx_sorted(j));
                idxi_cur = idxi(idx_sorted(j));
                
                params2 = struct2namevalue(p2.Unmatched);
                plot_pdc_dynamic_single(result, idxj_cur, idxi_cur, params2{:});
                save_tag = sprintf('-pdc-dynamic-single-j%d-i%d',...
                    idxj_cur, idxi_cur);
                
                % save
                save_fig2('path',outdir,'tag', [name save_tag]);
            end
            % don't use common save
            flag_save = false;
        otherwise
            error('unknown mod %s',p.Results.mode)
    end
    
    if flag_save
        % save
        save_fig2('path',outdir,'tag', [name save_tag]);
    end
    
end

end