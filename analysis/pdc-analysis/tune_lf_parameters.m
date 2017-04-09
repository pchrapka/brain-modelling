function tune_lf_parameters(sources_mini_file,outdir,varargin)

p = inputParser();
addRequired(p,'sources_mini_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'ntrials',10,@isnumeric);
addParameter(p,'order',1:14,@(x) isnumeric(x) && isvector(x));
addParameter(p,'lambda',[0.9:0.02:0.98 0.99],@(x) isnumeric(x) && isvector(x));
addParameter(p,'gamma',[1e-4 1e-3 1e-2 0.1 1 10],@(x) isnumeric(x) && isvector(x));
addParameter(p,'plot',true,@islogical);
addParameter(p,'plot_crit','ewaic',@ischar);
addParameter(p,'plot_orders',[],@isnumeric);
parse(p,sources_mini_file,outdir,varargin{:});

%% set lattice options
% get nchannels from sources data
sources = loadfile(sources_mini_file);
nchannels = size(sources,1);

filters = {};
labels = {};
k = 1;

order_max = max(p.Results.order);
for i=1:length(p.Results.lambda)
    for j=1:length(p.Results.gamma)
        % tuning each parameter combination
        filters{k} = MCMTLOCCD_TWL4(nchannels,order_max,p.Results.ntrials,...
            'lambda',p.Results.lambda(i),'gamma',p.Results.gamma(j));
        labels{k} = sprintf('lambda %0.3g gamma %0.3f',...
            p.Results.lambda(i),p.Results.gamma(j));
        k = k+1;
    end
end

%% run lattice filters
% set up parfor
parfor_setup('cores',12,'force',true);

% filter results are dependent on all input file parameters
[~,exp_name,~] = fileparts(sources_mini_file);

verbosity = 0;
lf_files = run_lattice_filter(...
    sources_mini_file,...
    'basedir',outdir,...
    'outdir',exp_name,... 
    'filters', filters,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',false,...
    'verbosity',verbosity,...
    'tracefields', {'Kf','Kb','Rf','ferror','berrord'},...
    'plot_pdc', false);

%% set up view lattice
if p.Results.plot
    if isempty(p.Results.plot_orders)
        plot_orders = p.Results.order;
    else
        plot_orders = p.Results.plot_orders;
    end
    
    view_lf = ViewLatticeFilter(lf_files,'labels',labels);
    crit_time = {'ewaic','normtime'};
    view_lf.compute(crit_time);
    if length(p.Results.lambda) ~= 1 && length(p.Results.gamma) ~= 1
        view_lf.plot_criteria_surface(...
            'criteria',p.Results.plot_crit,...
            'orders',plot_orders,...
            'file_list',1:length(lf_files));
    else
        view_lf.plot_criteria_vs_order_vs_time(...
                'criteria',p.Results.plot_crit,...
                'orders',plot_orders,...
                'file_list',1:length(lf_files));
    end
end

end