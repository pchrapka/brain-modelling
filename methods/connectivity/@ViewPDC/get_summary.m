function out = get_summary(obj,varargin)
%PDC_GET_SUMMARY summarizes magnitude of PDC data for each channel pair
%   PDC_GET_SUMMARY() summarizes magnitude of PDC data for each channel
%   pair
%   
%   Parameters
%   ----------
%   outdir (string)
%       output directory for summary data
%       by default uses output directory set in ViewPDC.outdir, can be
%       overriden here with:
%       1. 'data' - same directory where data is located
%       2. any regular path
%   save (logical, default = false)
%       flag to save summary to data file
%
%   Output
%   ------
%   struct with the following fields
%   mag (vector)
%       sum of PDC for channel pair
%   idxj (vector)
%       corresponding jth-channel index, also row index
%   idxi (vector)
%       corresponding ith-channel index, also column index
%   idx_sorted (vector)
%       indices for magnitude sorted in descending order
%   dims (vector)
%       dimensions of pdc data

p = inputParser();
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
parse(p,varargin{:});

% set up output file
obj.save_tag = '-summary';
outdir = obj.get_outdir(p.Results.outdir);
outfile = obj.get_savefile();
outfile_pdc = fullfile(outdir,[outfile '.mat']);

% check pdc freshness
fresh = obj.check_pdc_freshness(outfile_pdc);

if fresh || ~exist(outfile_pdc,'file')
    % compute summary
    fprintf('computing pdc summary\n');
    
    % load data
    obj.load();
    
    fprintf('summarizing data\n');
    
    dims = size(obj.pdc);
    [~,nchannels,~,nfreqs] = size(obj.pdc);
   
    
    w = 0:nfreqs-1;
    w = w/(2*nfreqs);
    
    w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
    f = w(w_idx)*obj.fs;
    freq_idx = 1:nfreqs;
    freq_idx = freq_idx(w_idx);
    
    ichannel_idx = zeros(nchannels, nchannels);
    jchannel_idx = zeros(nchannels, nchannels);
    data_metric_matrix = zeros(nchannels, nchannels);
    for j=1:nchannels
        for i=1:nchannels
            % data
            if j ~= i
                
                data_temp = abs(squeeze(obj.pdc(:,i,j,freq_idx))');
                
                ichannel_idx(j,i) = i;
                jchannel_idx(j,i) = j;
                data_metric_matrix(j,i) = sum(data_temp(:));
            end
            
        end
    end
    
    data_metric = data_metric_matrix(:);
    ichannel_idx = ichannel_idx(:);
    jchannel_idx = jchannel_idx(:);
    
    % sort descending
    [~,idx_sorted] = sortrows(data_metric,-1);
    
    out = [];
    out.mag = data_metric;
    out.mag_matrix = data_metric_matrix;
    out.idxj = jchannel_idx;
    out.idxi = ichannel_idx;
    out.dims = dims;
    out.idx_sorted = idx_sorted;
    
    if p.Results.save
        save_parfor(outfile_pdc, out);
    end
else
    print_msg_filename(outfile_pdc,'loading');
    out = loadfile(outfile_pdc);
end

obj.save_tag = [];

end