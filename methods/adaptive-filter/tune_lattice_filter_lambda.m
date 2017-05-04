function lambda_opt = tune_lattice_filter_lambda(tune_file,outdir,varargin)
%   Parameters
%   ----------
%   outdir
%       output directory for temp files, the name should reflect the
%       tune_file and the current filter parmeters
%   filter_params
%       requires the following fields: nchannels,norder,ntrials

p = inputParser();
p.StructExpand = false;
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'filter','MCMTLOCCD_TWL4',@ischar);
addParameter(p,'filter_params',[],@isstruct);
addParameter(p,'gamma_opt',[],@isnumeric);
default_lambda = [0.9:0.02:0.98 0.99];
addParameter(p,'lambda',default_lambda,@isnumeric);
addParameter(p,'run_options',{},@iscell);
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
addParameter(p,'plot_lambda',false,@islogical);
parse(p,tune_file,outdir,varargin{:});

% check filter_params
fields = {'nchannels','norder','ntrials'};
for i=1:length(fields)
    if ~isfield(p.Results.filter_params,fields{i})
        error([mfilename ':input'],'missing field %s in filter_params',fields{i});
    end
end

% make sure only one order was specified
if length(p.Results.filter_params.norder) ~= 1
    error([mfilename ':input'],'specify only one order');
end

nlambda = length(p.Results.lambda);

% check gamma_opt
if length(p.Results.gamma_opt) ~= nlambda
    error([mfilename ':input'],...
        'not enough optimized gammas: got %d, expected %d',...
        length(p.Results.gamma_opt), nlambda);
end

%% set up filters

filters = cell(nlambda,1);
labels = cell(nlambda,1);
func_filter = str2func(p.Results.filter);

for i=1:nlambda
    % TODO the parameter order here is specific to MCMTLOCCD_TWL4, it's ok for now
    filter_params = {...
        p.Results.filter_params.nchannels,...
        p.Results.filter_params.norder,...
        p.Results.filter_params.ntrials,...
        'lambda',p.Results.lambda(i),...
        'gamma',p.Results.gamma_opt(i)};
    filters{i} = func_filter(filter_params{:});
    labels{i} = sprintf('lambda %0.3g gamma %0.3f',...
        p.Results.lambda(i),p.Results.gamma_opt(i));
end

%% run filters
% separate outdir into a basedir and outdir
[basedir,outdir2,~] = fileparts([outdir '.m']);

% run filter
lf_files = run_lattice_filter(...
    tune_file,...
    'basedir',basedir,...
    'outdir',outdir2,... 
    'filters', filters,...
    p.Results.run_options{:},...
    'force',false,...
    'verbosity',0,...
    'tracefields', {'Kf','Kb','Rf','ferror','berrord'});

%% compute criteria
view_lf = ViewLatticeFilter(lf_files,'labels',labels);
criteria = {'normerrortime'};
view_lf.compute(criteria);

crit_idx = p.Results.criteria_samples;
if isempty(crit_idx)
    % load one criteria to get samples
    crit_val = view_lf.get_criteria(...
        'criteria',criteria{1},...
        'orders',p.Results.filter_params.norder,...
        'file_list',1);
    nsamples = size(crit_val.f{1},2);
    
    % select all samples for mean
    crit_idx = [1 nsamples];
end

ndims = length(criteria)+1;
data = zeros(nlambda,ndims);
data(:,ndims) = p.Results.lambda;

for j=1:length(criteria)
    % get criteria
    crit_val = view_lf.get_criteria(...
        'criteria',criteria{j},...
        'orders',p.Results.filter_params.norder,...
        'file_list',1:nlambda);
        
    for k=1:nlambda
        
        % take mean of forward
        crit_mean_f = mean(crit_val.f{k}(crit_idx(1):crit_idx(2)));
        % take mean of backward
        crit_mean_b = mean(crit_val.b{k}(crit_idx(1):crit_idx(2)));
        
        % data = [criteria1 criteria2 lambda]
        data(k,j) = crit_mean_f + crit_mean_b;
        
    end
end

% find min criteria
[~,idx] = min(data(:,1));
lambda_opt = data(idx,ndims);

if p.Results.plot_lambda
    view_lf.plot_criteria_vs_order_vs_time(...
        'criteria',criteria{1},...
        'orders',p.Results.filter_params.norder,...
        'file_list',1:length(lf_files));
end

end