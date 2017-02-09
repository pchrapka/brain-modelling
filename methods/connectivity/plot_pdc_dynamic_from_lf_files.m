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
    
    % plot
    h = figure;
    colormap('jet');
    set(h,'NumberTitle','off','MenuBar','none', 'Name', files{i} );
    fprintf('plotting pdc for %s\n',name);
    
    p2 = inputParser();
    p2.KeepUnmatched = true;
    addParameter(p2,'w',[0 0.5],@isnumeric);
    parse(p2,p.Results.params{:});
    
    switch p.Results.mode
        case 'tiled'        
            print_msg_filename(files{i},'loading');
            result = loadfile(files{i});
            plot_pdc_dynamic(result,p.Results.params{:});
            save_tag = '-pdc-dynamic';
        case 'summary'
            print_msg_filename(files{i},'loading');
            result = loadfile(files{i});
            plot_pdc_dynamic_summary(result,p.Results.params{:});
            save_tag = '-pdc-dynamic-summary';
        case 'single'
            print_msg_filename(files{i},'loading');
            result = loadfile(files{i});
            plot_pdc_dynamic_single(result,p.Results.params{:});
            save_tag = sprintf('-pdc-dynamic-single-j%d-i%d',...
                p.Results.params{1},p.Results.params{2});
        case 'single-largest'
            ptemp = inputParser();
            ptemp.KeepUnmatched = true;
            addParameter(ptemp,'nplots',5,@isnumeric);
            addParameter(ptemp,'ChannelLabels',{},@iscell);
            parse(ptemp,p.Results.params{:});
            params2 = struct2namevalue(ptemp.Unmatched);
            
            freq_tag = sprintf('-%0.2f-%0.2f',p2.Results.w(1),p2.Results.w(2));
            
            % summarize data
            % load data in pdc_get_summary to save summary file
            [out,result] = pdc_get_summary(files{i}, params2{:});
            % re-use loaded pdc data
            
            if isempty(result)
                % pdc data has not been loaded
                print_msg_filename(files{i},'loading');
                result = loadfile(files{i});
            end
            
            % plot single and save each
            for j=1:ptemp.Results.nplots
                idxj_cur = out.idxj(out.idx_sorted(j));
                idxi_cur = out.idxi(out.idx_sorted(j));
                
                plot_pdc_dynamic_single(result, idxj_cur, idxi_cur,...
                    'ChannelLabels',ptemp.Results.ChannelLabels, params2{:});
                save_tag = sprintf('-pdc-dynamic-single-j%d-i%d',...
                    idxj_cur, idxi_cur);
                
                % save
                save_fig2('path',outdir,'tag', [name save_tag freq_tag]);
            end
            % don't use common save
            flag_save = false;
        otherwise
            error('unknown mod %s',p.Results.mode)
    end
    
    if flag_save
        freq_tag = sprintf('-%0.2f-%0.2f',p2.Results.w(1),p2.Results.w(2));
        % save
        save_fig2('path',outdir,'tag', [name save_tag freq_tag]);
    end
    
end

end