function outfiles = run_lattice_filter(datain,varargin)
%
%   Input
%   -----
%   datain (string)
%       filename that contains the data matrix or a struct with the field
%       data
%       data should have the size [channels time trials]
%
%   Parameters
%   ----------
%   outdir (string, default = 'lfoutput')
%       output directory
%   basedir (string, default = pwd)
%       base output directory, can be specified with a directory or an
%       m-file name, the output directory will be placed in this folder.
%       the default directory will be the current working folder.
%   filter (filter object)
%       filter object
%   warmup (cell array, default = {'noise'})
%       filter warmup options, specified by cell array and are executed in
%       that order 
%       options: data, flipdata, noise
%   tracefields (cell array, default = {'Kf','Kb'})
%       fields to save from LatticeTrace object
%   normalization (string, default = 'none')
%       normalization type, options: allchannels, eachchannel, none
%   force (logical, default = false)
%       force recomputation
%   verbosity (integer, default = 0)
%       verbosity level
%
%   Output
%   ------
%   outfiles (cell array)
%       cell array of file names, files contain filtered data for each
%       filter, same order as filters parameter

%% parse inputs
p = inputParser();
addRequired(p,'datain',@ischar);
addParameter(p,'outdir','lfoutput',@ischar);
addParameter(p,'basedir','',@ischar);
addParameter(p,'filter',[],@(x) (length(x) == 1) && isobject(x));
addParameter(p,'warmup',{'noise'},@iscell);
addParameter(p,'force',false,@islogical);
addParameter(p,'verbosity',0,@isnumeric);
addParameter(p,'tracefields',{'Kf','Kb'},@iscell);
options_norm = {'allchannels','eachchannel','none'};
addParameter(p,'normalization','none',@(x) any(validatestring(x,options_norm)));
addParameter(p,'permutations',false,@islogical);
addParameter(p,'npermutations',1,@isnumeric);
p.parse(datain,varargin{:});

outdir = setup_outdir(p.Results.basedir,p.Results.outdir);

% set up parfor
% parfor_setup();

%% set up data

% load data from file
datain = loadfile(p.Results.datain);
if ~isnumeric(datain)
    if isfield(datain,'data')
        datain = datain.data;
    else
        error('data in .mat file must be a matrix or contain a data field with a matrix');
    end
end

data_dims = size(datain);
if length(data_dims) == 2
    data_dims(3) = 1;
end

% data normalization
ntrials = data_dims(3);
switch p.Results.normalization
    case 'allchannels'
        for i=1:ntrials
            datain(:,:,i) = normalize(datain(:,:,i));
        end
    case 'eachchannel'
        for i=1:ntrials
            datain(:,:,i) = normalizev(datain(:,:,i));
        end
    case 'none'
        % do nothing
end
clear ntrials;

%% set up parfor

% check filter
filter = p.Results.filter;
if isprop(filter, 'ntrials')
    ntrials = filter.ntrials;
else
    ntrials = 1;
end

% check data size and filter size
if data_dims(1) ~= filter.nchannels
    error('channel mismatch between data and filter %s',filter.name);
elseif data_dims(3) < ntrials
    fprintf('trials\n\trequired: %d\n\thave: %d\n',ntrials,data_dims(3));
    error('trial mismatch between data and filter %s',filter.name);
end

% set up permutations
if p.Results.permutations
    npermutes = p.Results.npermutations;
    idx = cell(npermutes,1);
    idx{1} = 1:ntrials;
    for k=2:npermutes
        idx{k} = randsample(1:data_dims(3),ntrials);
    end
else
    npermutes = 1;
    idx{1} = 1:ntrials;
end

% copy fields for parfor
options = copyfields(p.Results,[],{...
    'datain','warmup','force','verbosity','tracefields'});

% allocate mem
outfiles = cell(npermutes,1);
large_error = zeros(npermutes,1);
large_error_name = cell(npermutes,1);

%% loop over params
parfor k=1:npermutes
    
    % set up filter slug
    slug_filter = strrep(filter.name,' ','-');
    slug_permute = sprintf('-p%d',k);
    
    outfile = fullfile(outdir,[slug_filter slug_permute '.mat']);
    outfiles{k} = outfile;
    
    if options.force || isfresh(outfile,options.datain) || ~exist(outfile,'file')
        fprintf('running: %s\n', slug_filter)
        
        trace = LatticeTrace(filter,'fields',options.tracefields);
        
        % run the filter on data
        trace.run(datain(:,:,idx{k}),...
            'warmup',options.warmup,...
            'verbosity',options.verbosity,...
            'mode','none');
        
        % copy the filter name
        trace.name = trace.filter.name;
        
        % save data
        trace.save('filename',outfile,'trial_idx',idx{k});
        
        % check mse from 0
        data_true_kf = zeros(size(trace.trace.Kf));
        data_mse = mse_iteration(trace.trace.Kf,data_true_kf);
        if any(data_mse > 10)
            large_error_name{k} = slug_filter;
            large_error(k) = true;
        end
    end
end

%% Print extra info
if any(large_error > 0)
    fprintf('large errors\n');
    for k=1:npermutes
        if large_error(k) > 0
            fprintf('\tfile: %s\n',large_error_name{k});
        end
    end
end

end