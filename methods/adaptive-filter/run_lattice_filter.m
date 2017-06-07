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
%
%   filter options
%   --------------
%   filters (cell array of filter objects)
%       cell array of filter objects
%   warmup (cell array, default = {'noise'})
%       filter warmup options, specified by cell array and are executed in
%       that order 
%       options: data, flipdata, noise
%   tracefields (cell array, default = {'Kf','Kb'})
%       fields to save from LatticeTrace object
%   normalization (string, default = 'none')
%       normalization type, options: allchannels, eachchannel, none
%
%   running options
%   ---------------
%   cores (integer)
%       number of cores to setup, if cores == 0 it defaults to the max for
%       that particular machine
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
addParameter(p,'filters',{},@iscell);
addParameter(p,'warmup',{'noise'},@iscell);
addParameter(p,'force',false,@islogical);
addParameter(p,'verbosity',0,@isnumeric);
addParameter(p,'tracefields',{'Kf','Kb'},@iscell);
options_norm = {'allchannels','eachchannel','none'};
addParameter(p,'normalization','none',@(x) any(validatestring(x,options_norm)));
addParameter(p,'permutations',false,@islogical);
addParameter(p,'npermutations',1,@isnumeric);
addParameter(p,'ncores',1,@isnumeric);
p.parse(datain,varargin{:});

outdir = setup_outdir(p.Results.basedir,p.Results.outdir);

% set up parfor
if p.Results.ncores > 1
    parfor_setup('cores',p.Results.ncores,'force',true);
end

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

% copy fields for parfor
options = copyfields(p.Results,[],{...
    'datain','warmup','force','verbosity','tracefields'});

if p.Results.permutations
    npermutes = p.Results.npermutations;
else
    npermutes = 1;
end

%% loop over params
options.outdir = outdir;
nfilters = length(p.Results.filters);
filters = p.Results.filters;

if nfilters > npermutes
    idx = cell(nfilters,1);
    data_filter = cell(nfilters,npermutes);
    for j=1:nfilters
       ntrials = check_filter(filters{j},data_dims);
       if p.Results.permutations
           idx(j,:) = create_permutations(npermutes,ntrials,data_dims(3));
       else
           idx{j,1} = 1:ntrials;
       end
       
       % rearrange data
       for k=1:npermutes
           data_filter{j,k} = datain(:,:,idx{j,k});
       end
    end
    
    parfor j=1:nfilters
        for k=1:npermutes
            out(j,k) = run_lattice_filter_inner(data_filter{j,k},filters{j},options,idx{j,k},k);
        end
    end
else
    idx = cell(nfilters,1);
    data_filter = cell(nfilters,npermutes);
    for j=1:nfilters
       ntrials = check_filter(filters{j},data_dims);
       if p.Results.permutations
           idx(j,:) = create_permutations(npermutes,ntrials,data_dims(3));
       else
           idx{j,1} = 1:ntrials;
       end
       
       % rearrange data
       for k=1:npermutes
           data_filter{j,k} = datain(:,:,idx{j,k});
       end
    end
    
    parfor k=1:npermutes
        for j=1:nfilters
            out(j,k) = run_lattice_filter_inner(data_filter{j,k},filters{j},options,idx{j,k},k);
        end
    end
end
outfiles = {out.outfile};

%% Print extra info
if any(out.large_error > 0)
    fprintf('large errors\n');
    for j=1:nfilters
        for k=1:npermutes
            if out(j,k).large_error > 0
                fprintf('\tfile: %s\n',out(j,k).large_error_name);
            end
        end
    end
end

end

function out = run_lattice_filter_inner(data_filter,filter,options,idx,iter)
% set up filter slug
slug_filter = strrep(filter.name,' ','-');
slug_permute = sprintf('-p%d',iter);

outfile = fullfile(options.outdir,[slug_filter slug_permute '.mat']);

out = [];
out.outfile = outfile;
out.large_error_name = '';
out.large_error = false;

if options.force || isfresh(outfile,options.datain) || ~exist(outfile,'file')
    fprintf('running: %s\n', slug_filter)
    
    trace = LatticeTrace(filter,'fields',options.tracefields);
    
    % run the filter on data
    trace.run(data_filter,...
        'warmup',options.warmup,...
        'verbosity',options.verbosity,...
        'mode','none');
    
    % copy the filter name
    trace.name = trace.filter.name;
    
    % save data
    trace.save('filename',outfile,'trial_idx',idx);
    
    % check mse from 0
    data_true_kf = zeros(size(trace.trace.Kf));
    data_mse = mse_iteration(trace.trace.Kf,data_true_kf);
    if any(data_mse > 10)
        out.large_error_name = slug_filter;
        out.large_error = true;
    end 
end

end

function ntrials = check_filter(filter,data_dims)
% check filter
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
end

function idx = create_permutations(npermutes,ntrials,ntrials_available)
% set up permutations
idx = cell(npermutes,1);
idx{1} = 1:ntrials;
for k=2:npermutes
    idx{k} = randsample(1:ntrials_available,ntrials);
end

end