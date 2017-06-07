function value = tune_lattice_filter(tune_file, outdir, varargin)
%TUNE_LATTICE_FILTER evalutes a lattice filter wrt a criteria
%   TUNE_LATTICE_FILTER(tune_file,outdir,...) evalutes a lattice filter wrt
%   a criteria. Returns a value describing the filter performance.
%
%   Input
%   -----
%   tune_file (string)
%       data file for tuning
%   outdir (string)
%       output directory for temp files, the name should reflect the
%       tune_file and the current filter parmeters
%       example:
%           outdir = data-set1/order4/lambda0.99
%
%   Parameters
%   ----------
%
%   filter options
%   --------------
%   filter (string, default = 'MCMTLOCCD_TWL4')
%       lattice filter to be tuned
%   filter_params (struct)
%       filter parameters for lattice filter constructor
%       requires the following fields: nchannels,norder,ntrials,lambda
%   run_options (cell)
%       options for run_lattice_filter function
%
%   criteria options
%   -----------------
%   criteria (cell, default = normerrortime)
%       criteria to be considered when evaluting the performance
%   criteria_mode (string, default = criteria_value)
%       criteria_value - mean of criteria of criteria_samples
%       criteria_target - error between the mean of criteria of
%       criteria_samples and the criteria_target option
%
%       if multiple criteria are specfied, then it's the sum
%
%   criteria_target (vector)
%       targets when criteria_mode = 'criteria_target', same length as
%       number of criteria
%   criteria_weight (vector)
%       weight applied to each criteria
%
%   criteria_samples (2x1 vector)
%       starting and ending indices for evaluating criteria

p = inputParser();
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'filter','MCMTLOCCD_TWL4',@ischar);
addParameter(p,'filter_params',{},@iscell);
addParameter(p,'run_options',{},@iscell);
addParameter(p,'criteria','normerrortime',@(x) ischar(x) || iscell(x));
addParameter(p,'criteria_mode','criteria_value',@ischar);
addParameter(p,'criteria_target',[],@isnumeric); % should be same length as criteria when criteria_mode = criteria_target
addParameter(p,'criteria_weight',[],@isnumeric); % should be same length as criteria when criteria_mode = criteria_value
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
parse(p,tune_file,outdir,varargin{:});

func_filter = str2func(p.Results.filter);
filter = func_filter(p.Results.filter_params{:});

% separate outdir into a basedir and outdir
[basedir,outdir2,~] = fileparts([outdir '.m']);

% run filter
lf_files = run_lattice_filter(...
    tune_file,...
    'basedir',basedir,...
    'outdir',outdir2,... 
    'filters', {filter},...
    p.Results.run_options{:},...
    'force',false,...
    'verbosity',0,...
    'tracefields', {'Kf','Kb','Rf','ferror','berrord'});

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
crit_weight = p.Results.criteria_weight;
if isempty(crit_weight)
    crit_weight = ones(length(criteria),1);
end

switch p.Results.criteria_mode
    case 'criteria_value'
        crit_val = [];
        for i=1:length(criteria)
            crit_val_f = view_lf.criteria.(criteria{i}).f(end,:);
            crit_val_b = view_lf.criteria.(criteria{i}).b(end,:);
            
            crit_val(i) = mean(crit_val_f(crit_idx(1):crit_idx(2))) + ...
                mean(crit_val_b(crit_idx(1):crit_idx(2)));
        end
        crit_val = crit_val.*crit_weight;
        value = norm(crit_val);
        %value = sum(crit_val);
        
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

fprintf('value: %g\n',value);

end