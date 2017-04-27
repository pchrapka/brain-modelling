function value = tune_lattice_filter(tune_file, outdir, varargin)

p = inputParser();
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'filter','MCMTLOCCD_TWL4',@ischar);
addParameter(p,'filter_params',{},@iscell);
addParameter(p,'run_options',{},@iscell);
addParameter(p,'criteria_mode','criteria_value',@ischar);
addParameter(p,'criteria','normerrortime',@(x) ischar(x) || iscell(x));
addParameter(p,'criteria_target',[],@isnumeric); % should be same length as criteria when criteria_mode = criteria_target
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
parse(p,tune_file,outdir,varargin{:});

func_filter = str2func(p.Results.filter);
filters{1} = func_filter(p.Results.filter_params{:});

% filter results are dependent on all input file parameters
[~,exp_name,~] = fileparts(tune_file);

% run filter
lf_files = run_lattice_filter(...
    tune_file,...
    'basedir',outdir,...
    'outdir',exp_name,... 
    'filters', filters,...
    p.Results.run_options{:},...
    'force',false,...
    'verbosity',0,...
    'tracefields', {'Kf','Kb','Rf','ferror','berrord'},...
    'plot_pdc', false);

% evaluate criteria
view_lf = ViewLatticeFilter(lf_files);

criteria = p.Results.criteria;
if ischar(p.Results.criteria)
    criteria = {p.Results.criteria};
end
view_lf.compute(criteria);

crit_idx = p.Results.criteria_samples;
if isempty(crit_idx)
    crit_idx = [1 length(crit_val)];
end

switch p.Results.criteria_mode
    case 'criteria_value'
        if length(criteria) > 1
            error('can only use one criteria in this mode');
        end
        crit_val_f = view_lf.criteria.(criteria).f(end,:);
        crit_val_b = view_lf.criteria.(criteria).b(end,:);
        
        value = mean(crit_val_f(crit_idx(1):crit_idx(2))) + ...
            mean(crit_val_b(crit_idx(1):crit_idx(2)));
        fprintf('value: %g\n',value);
        
    case 'criteria_target'
        crit_error = [];
        for i=1:length(criteria)
            crit_val_f = view_lf.criteria.(criteria{i}).f(end,:);
            crit_val_b = view_lf.criteria.(criteria{i}).b(end,:);
            
            avg_f = mean(crit_val_f(crit_idx(1):crit_idx(2)));
            avg_b = mean(crit_val_b(crit_idx(1):crit_idx(2)));
            
            crit_error(i) = abs((avg_f + avg_b) - p.Results.criteria_target(i));
        end
        
        value = sum(crit_error);
        
    otherwise
        error('unknown criteria mode %s',p.Results.criteria_mode);
end


delete(lf_files{1});
delete(view_lf.criteriafiles{1});

end