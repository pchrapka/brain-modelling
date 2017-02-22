function outfiles = run_lattice_filter(script_name,datain,varargin)
%
%   Input
%   -----
%   script_name (string)
%       full file name of the benchmark script, including the extension
%
%       example:
%           script_name = [mfilename('fullpath') '.m'];
%
%       the path is used as the base folder for all outputs, so the
%       folder will look like
%
%       script_folder/
%           -> [name parameter]/    filtered data
%           -> img/                 plots generated by the benchmark
%
%   datain (matrix/string)
%       data matrix or filename that contains the data matrix
%       data should have the size [channels time trials]
%
%   Parameters
%   ----------
%   name (string, default = 'lf1')
%       analysis name
%   filters (cell array)
%       array of filter objects
%   warmup_noise (logical, default = true)
%       flag for warming up the filter with noise, this helps with filter
%       initialization
%   warmup_data (logical, default = false)
%       flag for warming up the filter with data, this helps with filter
%       initialization
%   force (logical, default = false)
%       force recomputation
%   verbosity (integer, default = 0)
%       verbosity level
%
%   plot_pdc (logical, default = true)
%       flag for plotting the pdc for each filter
%
%   Output
%   ------
%   outfiles (cell array)
%       cell array of file names, files contain filtered data for each
%       filter, same order as filters parameter

%% parse inputs
p = inputParser();
addRequired(p,'script_name',@ischar);
addRequired(p,'datain',@(x) isnumeric(x) || ischar(x));
addParameter(p,'name','lf1',@ischar);
addParameter(p,'filters',[]);
addParameter(p,'warmup_noise',true,@islogical);
addParameter(p,'warmup_data',false,@islogical);
addParameter(p,'force',false,@islogical);
addParameter(p,'verbosity',0,@isnumeric);
addParameter(p,'plot_pdc',true,@islogical);
addParameter(p,'tracefields',{'Kf','Kb'},@iscell);
p.parse(script_name,datain,varargin{:});

% copy filters
filters = p.Results.filters;
nfilters = length(filters);

[expdir,~,ext] = fileparts(p.Results.script_name);
if isempty(ext)
    error('missing file name in script_name');
end
if ~isempty(p.Results.name)
    outdir = fullfile(expdir,p.Results.name);
else
    outdir = fullfile(expdir,'output');
end
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% set up parfor
parfor_setup();

%% set up data

% load data
if ischar(p.Results.datain)
    % from file
    datain = loadfile(p.Results.datain);
    if ~isnumeric(datain)
        error('data in .mat file must be a matrix');
    end
    data_time = get_timestamp(p.Results.datain);
else
    data_time = now();
end
data_dims = size(datain);
if length(data_dims) == 2
    data_dims(3) = 1;
end


%% loop over params

% allocate mem
large_error = zeros(nfilters,1);
large_error_name = cell(nfilters,1);

estimate_kf = cell(nfilters,1);
estimate_kb = cell(nfilters,1);

% copy fields for parfor, don't want to pass another copy of datain if it's
% a struct
options = copyfields(p.Results,[],{...
    'warmup_noise','warmup_data','force','verbosity','tracefields'});

nchannels = filters{1}.nchannels;
outfiles = cell(nfilters,1);

% parfor k=1:nfilters
for k=1:nfilters
    
    % copy sim parameters
    filter = filters{k};
    if isprop(filter, 'ntrials')
        ntrials = filter.ntrials;
    else
        ntrials = 1;
    end
    
    if p.Results.warmup_data
        ntrials_req = 2*ntrials;
    else
        ntrials_req = ntrials;
    end
    
    % check data size and filter size
    if data_dims(1) ~= filter.nchannels
        error('channel mismatch between data and filter %s',filter.name);
    elseif data_dims(3) < ntrials_req
        fprintf('trials\n\trequired: %d\n\thave: %d\n',ntrials_req,data_dims(3));
        error('trial mismatch between data and filter %s',filter.name);
    end
    
    % set up filter slug
    slug_filter = filter.name;
    slug_filter = strrep(slug_filter,' ','-');
    outfile = fullfile(outdir,[slug_filter '.mat']);
    outfiles{k} = outfile;
    
    fresh = false;
    
    if exist(outfile,'file')
        % check freshness of data and filter analysis
        filter_time = get_timestamp(outfile);
        if data_time > filter_time
            fresh = true;
        end
    end
    
    if options.force || fresh || ~exist(outfile,'file')
        fprintf('running: %s\n', slug_filter)
        
        trace = LatticeTrace(filter,'fields',options.tracefields);
        
        ntime = size(datain,2);
        
        % warmup filter with noise
        if options.warmup_noise
            fprintf('warming up with noise\n');
            noise = gen_noise(nchannels, ntime, ntrials);
            
            % run filter on noise
            warning('off','all');
            try
                trace.warmup(noise);
            catch me
                msgText = getReport(me);
                warning('on','all');
                warning(msgText);
            end
            warning('on','all');
        end
        
        % warmup filter with simulated data
        if options.warmup_data
            fprintf('warming up with data\n');
            
            % use last
            idx_start = ntrials + 1;
            idx_end = idx_start + ntrials - 1;
            
            idx_start_wu = 1;
            idx_end_wu = idx_start_wu + ntrials - 1;
            
            % warm up filter on some data
            warning('off','all');
            try
                trace.warmup(datain(:,:,idx_start_wu:idx_end_wu));
            catch me
                msgText = getReport(me);
                warning('on','all');
                warning(msgText);
            end
            warning('on','all');
        else
            idx_start = 1;
            idx_end = idx_start + ntrials - 1;
        end
        
        % run the filter on data
        warning('off','all');
        try
            trace.run(datain(:,:,idx_start:idx_end),...
                'verbosity',options.verbosity,...
                'mode','none');
        catch me
            msgText = getReport(me);
            warning('on','all');
            warning(msgText);
        end
        warning('on','all');
        
        % copy the filter name
        trace.name = trace.filter.name;
        
        % save data
        data = [];
        for i=1:length(options.tracefields)
            field = options.tracefields{i};
            data.estimate.(field) = trace.trace.(field);
        end
        save_parfor(outfile,data);
        
        % check mse from 0
        data_true_kf = zeros(size(trace.trace.Kf));
        data_mse = mse_iteration(trace.trace.Kf,data_true_kf);
        if any(data_mse > 10)
            large_error_name{k} = slug_filter;
            large_error(k) = true;
        end
    end
end
    
if p.Results.plot_pdc
    error('use ViewPDC');
end

%% Print extra info
if any(large_error > 0)
    fprintf('large errors\n');
    for k=1:nfilters
        if large_error(k) > 0
            fprintf('\tfile: %s\n',large_error_name{k});
        end
    end
end

end