function gamma_opt = tune_lattice_filter_gamma(tune_file,outdir,varargin)
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
%   optimization options
%   --------------------
%   mode (string, default = 'existing')
%       mode of operation
%
%       existing - uses existing data only, does not run additional
%       optimization iterations
%       continue - uses existing data and runs additional iterations up to
%       maxevals
%
%   criteria_samples (2x1 vector)
%       starting and ending indices for evaluating criteria
%   
%   gamma options
%   -------------
%   upper_bound (numeric, default = 100)
%       upper bound for gamma
%   lower_bound (numeric, default = 10^(-10))
%       lower bound for gamma
%
%   plot_gamma (logical, default = false)
%       plots the criteria value vs gamma

p = inputParser();
p.StructExpand = false;
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'filter','MCMTLOCCD_TWL4',@ischar);
addParameter(p,'filter_params',[],@isstruct);
% default_gamma_exp = linspace(-14,2,10);
% default_gamma = 10.^default_gamma_exp;
addParameter(p,'upper_bound',100,@isnumeric);
addParameter(p,'lower_bound',10^(-10),@isnumeric);
addParameter(p,'run_options',{},@iscell);
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
addParameter(p,'plot_gamma',false,@islogical);
options_mode = {'existing','continue'};
addParameter(p,'mode','existing',@(x) any(validatestring(x,options_mode)));
parse(p,tune_file,outdir,varargin{:});

% check filter_params
fields = {'nchannels','norder','ntrials','lambda'};
for i=1:length(fields)
    if ~isfield(p.Results.filter_params,fields{i})
        error([mfilename ':input'],'missing field %s in filter_params',fields{i});
    end
end

% set up filter params
filter_params = {...
    p.Results.filter_params.nchannels,...
    p.Results.filter_params.norder,...
    p.Results.filter_params.ntrials,...
    'lambda',p.Results.filter_params.lambda};

criteria = {'mserrortime','meannorm1coefs_time'};
criteria_weight = [1e5 1];
% criteria_weight = [600 1];
% criteria_weight = [1 1];
% criteria = {'mserrortime'};
% criteria = {'meannorm1coefs_time'};

% set up optimization function
func_opt = @(x) tune_lattice_filter(...
    tune_file,...
    outdir,...
    'filter',p.Results.filter,...
    'filter_params',[filter_params, 'gamma',10^(x(1))],...
    'run_options',p.Results.run_options,...
    'criteria',criteria,...
    'criteria_mode','criteria_value',...
    'criteria_weight',criteria_weight,... penalize mserrortime
    'criteria_samples',p.Results.criteria_samples);

% find existing lattice filter runs, that are still fresh
filter_func = str2func(p.Results.filter);
filter_obj = filter_func(filter_params{:},'gamma',1);
filter_name = strrep([filter_obj.name '.mat'],' ','-');

pattern_search = strrep(filter_name,'gamma1.000e+00','gamma*');
files = dir(fullfile(outdir,pattern_search));
data_old = [];
count = 1;
for i=1:length(files)
    pattern = strrep(pattern_search,'*','(\d\.\d{3}e[+-]\d{2})');
    result = regexp(files(i).name,pattern,'tokens');
    if ~isempty(result)
        gamma = str2double(result{1}{1});
        
        if ~isfresh(fullfile(outdir,files(i).name),tune_file)
            % get the criteria value if the filtered data is still current
            data_old(count).gamma = gamma;
            data_old(count).value = func_opt(log10(gamma));
            count = count + 1;
        end
    end
end

% set default optimization parameters
lb = p.Results.lower_bound;
ub = p.Results.upper_bound;
maxevals = 20;

% utilize old data
if ~isempty(data_old)
    data_plot = [];
    data_plot(1,:) = [data_old.gamma];
    data_plot(2,:) = [data_old.value];
    data_plot = data_plot';
    data_plot = sortrows(data_plot,1);
        
    if p.Results.plot_gamma    
        figure;
        semilogx(data_plot(:,1),data_plot(:,2),'-o');
        xlabel('gamma');
        ylabel('criteria');
        drawnow;
    end
    
    % adjust optimization parameters
    [~,idx] = min(data_plot(:,2));
    idx_prev = idx-1;
    idx_next = idx+1;
    if idx_prev < 1
        lb = p.Results.lower_bound;
    else
        lb = data_plot(idx_prev,1);
    end
    if idx_next > length(data_old)
        ub = p.Results.upper_bound;
    else
        ub = data_plot(idx_next,1);
    end
    
    switch p.Results.mode
        case 'existing'
            % use existing data
            maxevals = 0;
        case 'continue'
            % continue with optimization
            maxevals = maxevals - length(data_old);
        otherwise
            error('unknown mode');
    end
end

if maxevals <= 0
    gamma_opt = data_plot(idx,1);
else    
    % optimize the exponent on gmma
    options = optimset(...
        'MaxFunEvals',maxevals,...
        'TolX',0.2,...
        'Display','iter');
    %'PlotFcns',@optimplotfval);
    gamma_exp_opt = fminbnd(func_opt,...
        log10(lb),...
        log10(ub),...
        options);
    gamma_opt = 10^gamma_exp_opt;
    
    
end

fprintf('set gamma to %g\n',gamma_opt);

end
