function pdc_files = rc2pdc_dynamic_from_lf_files(files,varargin)
%RC2PDC_DYNAMIC_FROM_LF_FILES computes dynamic PDC of lattice filtered data
%   RC2PDC_DYNAMIC_FROM_LF_FILES(files,...) computes dynamic PDC of lattice
%   filtered data. It also saves the conversion from RC to PDC in the same
%   directory as the filtered data.
%
%   Input
%   -----
%   files (cell array/string)
%       file names of data created by run_lattice_filter, the required
%       fields are Kf, Kb and Rf
%
%   Parameters
%   ----------
%   params (cell array)
%       additional arguments and name value parameters for rc2dpdc_ynamic
%
%   Output
%   ------
%   pdc_files (cell array)
%       cell array of files containing pdc daata

p = inputParser();
addRequired(p,'files',@(x) ischar(x) || iscell(x))
addParameter(p,'params',{},@iscell);
parse(p,files,varargin{:});

p2 = inputParser();
p2.KeepUnmatched = true;
addParameter(p2,'metric','euc',@ischar);
parse(p2,p.Results.params{:});

if ischar(p.Results.files)
    files = {p.Results.files};
end

pdc_files = cell(length(files),1);
for i=1:length(files)
    % set up save params
    [data_path,name,~] = fileparts(files{i});
    
    % create pdc output file name
    outfile_pdc = fullfile(data_path,sprintf('%s-pdc-dynamic-%s.mat',name,p2.Results.metric));
    
    % check pdc freshness
    fresh = false;
    if exist(outfile_pdc,'file')
        data_time = get_timestamp(files{i});
        pdc_time = get_timestamp(outfile_pdc);
        if data_time > pdc_time
            fresh = true;
        end
    end
    
    % load pdc
    if fresh || ~exist(outfile_pdc,'file')
        fprintf('computing pdc from rc for %s\n',name);
        print_msg_filename(files{i},'loading');
        data = loadfile(files{i});
        
        % convert rc to pdc
        result = rc2pdc_dynamic(data.estimate.Kf,data.estimate.Kb,...
            data.estimate.Rf,...
            p.Results.params{:});
        save_parfor(outfile_pdc,result);
    else
        fprintf('already computed pdc %s from rc for %s\n',p2.Results.metric,name);
    end
    
    pdc_files{i} = outfile_pdc;
    
end

end