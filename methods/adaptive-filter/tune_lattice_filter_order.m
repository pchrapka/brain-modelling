function order_opt = tune_lattice_filter_order(tune_file,outdir,varargin)
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
addParameter(p,'lambda_opt',[],@isnumeric);
default_order = 1:14;
addParameter(p,'order',default_order,@isnumeric);
addParameter(p,'run_options',{},@iscell);
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
addParameter(p,'plot_order',false,@islogical);
parse(p,tune_file,outdir,varargin{:});

% check filter_params
fields = {'nchannels','ntrials'};
for i=1:length(fields)
    if ~isfield(p.Results.filter_params,fields{i})
        error([mfilename ':input'],'missing field %s in filter_params',fields{i});
    end
end

norder = length(p.Results.order);

% check gamma_opt
if length(p.Results.gamma_opt) ~= norder
    error([mfilename ':input'],...
        'not enough optimized gammas: got %d, expected %d',...
        length(p.Results.gamma_opt), norder);
end

% check lambda_opt
if length(p.Results.lambda_opt) ~= norder
    error([mfilename ':input'],...
        'not enough optimized lambdas: got %d, expected %d',...
        length(p.Results.lambda_opt), norder);
end

%% set up filters

filters = cell(norder,1);
labels = cell(norder,1);
func_filter = str2func(p.Results.filter);

for i=1:norder
    % TODO the parameter order here is specific to MCMTLOCCD_TWL4, it's ok for now
    filter_params = {...
        p.Results.filter_params.nchannels,...
        p.Results.order(i),...
        p.Results.filter_params.ntrials,...
        'lambda',p.Results.lambda_opt(i),...
        'gamma',p.Results.gamma_opt(i)};
    filters{i} = func_filter(filter_params{:});
    labels{i} = sprintf('order %d lambda %0.3g gamma %0.3f',...
        p.Results.order(i),p.Results.lambda_opt(i),p.Results.gamma_opt(i));
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
criteria = {'ewaic'};
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
data = zeros(norder,ndims);
data(:,ndims) = p.Results.order;

for j=1:length(criteria)
        
    for k=1:norder
        % get criteria
        crit_val = view_lf.get_criteria(...
            'criteria',criteria{j},...
            'orders',p.Results.order(k),...
            'file_list',k);
        
        % take mean of forward
        crit_mean_f = mean(crit_val.f{1}(crit_idx(1):crit_idx(2)));
        % % take mean of backward
        % crit_mean_b = mean(crit_val.b{1}(crit_idx(1):crit_idx(2)));
        
        % data = [criteria1 criteria2 order]
        data(k,j) = crit_mean_f; % + crit_mean_b;
        
    end
end

% find min criteria
[~,idx] = min(data(:,1));
order_opt = data(idx,ndims);

% if p.Results.plot_order
%     % TODO not sure this would work
%     % FIXME change orders
%     view_lf.plot_criteria_vs_order_vs_time(...
%         'criteria',criteria{1},...
%         'orders',1:p.Results.filter_params.norder,...
%         'file_list',1:length(lf_files));
% end

end