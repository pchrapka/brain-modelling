function value = tune_lattice_filter(data_file, outdir, varargin)

p = inputParser();
addRequired(p,'data_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'filter','MCMTLOCCD_TWL4',@ischar);
addParameter(p,'filter_params',{},@iscell);
addParameter(p,'criteria','normtime',@ischar);
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
parse(p,varargin{:});

func_filter = str2func(p.Results.filter);
filters{1} = func_filter(p.Results.filter_params);

% filter results are dependent on all input file parameters
[~,exp_name,~] = fileparts(data_file);

% run filter
lf_files = run_lattice_filter(...
    data_file,...
    'basedir',outdir,...
    'outdir',exp_name,... 
    'filters', filters,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',false,...
    'verbosity',verbosity,...
    'tracefields', {'Kf','Kb','Rf','ferror','berrord'},...
    'plot_pdc', false);

% evaluate criteria
view_lf = ViewLatticeFilter(lf_files);
view_lf.compute({p.Results.criteria});

crit_val = view_lf.criteria.(p.Results.criteria).f(end,:);

crit_idx = p.Results.criteria_samples;
if isempty(crit_idx)
    crit_idx = [1 length(crit_val)];
end
value = mean(crit_val(crit_idx(1):crit_idx(2)));

end