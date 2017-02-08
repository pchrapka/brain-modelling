function out = pdc_get_summary(data,varargin)
%PDC_GET_SUMMARY summarizes magnitude of PDC data for each channel pair
%   PDC_GET_SUMMARY(data) summarizes magnitude of PDC data for each channel
%   pair
%
%   Input
%   -----
%   
%   Parameters
%   ----------
%   data (string/struct)
%       pdc output struct or data file
%   w (vector, default = [0 0.5])
%       normalized frequency range
%   fs (number,default= 1)
%       sampling frequency
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
addRequired(p,'data',@(x) ischar(x) || isstruct(x));
addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2));
addParameter(p,'fs',1,@isnumeric);
parse(p,data,varargin{:});

if ischar(data)
    file = data;
    [data_path,name,~] = fileparts(file);
    outfile_pdc = fullfile(data_path,...
        sprintf('%s-pdc-summary-%0.2f-%0.2f.mat',...
        name,p.Results.w(1),p.Results.w(2)));
    
    % check pdc freshness
    fresh = false;
    if exist(outfile_pdc,'file')
        data_time = get_timestamp(file);
        pdc_time = get_timestamp(outfile_pdc);
        if data_time > pdc_time
            fresh = true;
        end
    end
    
    save_output = true;
else
    file = [];
    fresh = true;
    outfile_pdc = [];
    save_output = fales;
end

if fresh || ~exist(outfile_pdc,'file')
    % compute summary
    fprintf('computing pdc summary for %s\n',name);
    
    % load data
    if ~isempty(file)
        print_msg_filename(file,'loading');
        data = loadfile(file);
    end
    
    fprintf('summarizing data\n');
    
    dims = size(data.pdc);
    ndims = length(dims);
    if ndims == 4
        % dynamic pdc
        [nsamples,nchannels,~,nfreqs]=size(data.pdc);
    else
        error('requires dynamic pdc data');
    end
    
    fs = p.Results.fs;
    
    if p.Results.w(1) < 0 || p.Results.w(2) > 0.5
        disp(p.Results.w);
        error('w range too wide should be between [0 0.5]');
    end
    
    w = 0:nfreqs-1;
    w = w/(2*nfreqs);
    
    w_idx = (w >= p.Results.w(1)) & (w <= p.Results.w(2));
    f = w(w_idx)*fs;
    freq_idx = 1:nfreqs;
    freq_idx = freq_idx(w_idx);
    
    ichannel_idx = zeros(nchannels, nchannels);
    jchannel_idx = zeros(nchannels, nchannels);
    data_metric = zeros(nchannels, nchannels);
    for j=1:nchannels
        for i=1:nchannels
            % data
            if j ~= i
                
                data_temp = abs(squeeze(data.pdc(:,i,j,freq_idx))');
                
                ichannel_idx(j,i) = i;
                jchannel_idx(j,i) = j;
                data_metric(j,i) = sum(data_temp(:));
            end
            
        end
    end
    
    data_metric = data_metric(:);
    ichannel_idx = ichannel_idx(:);
    jchannel_idx = jchannel_idx(:);
    
    % sort descending
    [~,idx_sorted] = sortrows(data_metric,-1);
    
    out = [];
    out.mag = data_metric;
    out.idxj = jchannel_idx;
    out.idxi = ichannel_idx;
    out.dims = dims;
    out.idx_sorted = idx_sorted;
    
    if save_output
        save_parfor(outfile_pdc, out);
    end
else
    print_msg_filename(outfile_pdc,'loading');
    out = loadfile(outfile_pdc);
end


end