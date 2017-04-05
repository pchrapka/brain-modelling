function tune_trials(pipeline,outdir,varargin)

p = inputParser();
addRequired(p,'pipeline',@(x) isa(x,'ftb.AnalysisBeamformer'));
addRequired(p,'outdir',@ischar);
addParameter(p,'patch_type','aal',@ischar);
addParameter(p,'ntrials',[1 2 5 10 15 20 40],@(x) isnumeric(x) && isvector(x));
addParameter(p,'order',6,@(x) isnumeric(x) && length(x) == 1);
addParameter(p,'lambda',0.99,@(x) isnumeric(x) && length(x) == 1);
addParameter(p,'gamma',1e-2,@(x) isnumeric(x) && length(x) == 1);
addParameter(p,'normalization','allchannels',@ischar); % also none
addParameter(p,'envelope',false,@islogical); % also none
addParameter(p,'plot',true,@islogical);
addParameter(p,'plot_crit','normtime',@ischar);
addParameter(p,'plot_orders',[],@isnumeric);
parse(p,pipeline,outdir,varargin{:});

lf_file = pipeline.steps{end}.lf.leadfield;
sources_file = pipeline.steps{end}.sourceanalysis;

%% set lattice options
lf = loadfile(lf_file);
patch_labels = lf.filter_label(lf.inside);
patch_labels = cellfun(@(x) strrep(x,'_',' '),...
    patch_labels,'UniformOutput',false);
npatch_labels = length(patch_labels);
clear lf;

nchannels = npatch_labels;

%% set up filters
filters = {};
data_labels = {};
% tuning over triasls
for k=1:length(p.Results.ntrials)
    ntrial_cur = p.Results.ntrials(k);
    data_labels{k} = sprintf('%d trials',ntrial_cur);
    filters{k} = MCMTLOCCD_TWL4(nchannels,p.Results.order,ntrial_cur,...
        'lambda',p.Results.lambda,'gamma',p.Results.gamma);
end

%% lattice filter

% set up parfor
parfor_setup('cores',12,'force',true);

verbosity = 0;
lf_files = lattice_filter_sources(filters, sources_file,...
    'normalization',p.Results.normalization,...
    'envelope',p.Results.envelope,...
    'tracefields',{'Kf','Kb','Rf','ferror','berrord'},...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% plot criteria for each trial
crit_all = {'normtime'};%{'aic','ewaic','normtime'};

if p.Results.plot
    for k=1:length(lf_files)
        view_lf = ViewLatticeFilter(lf_files{k});
        view_lf.compute(crit_all);
        
        switch p.Results.plot_crit
            case {'ewaic','ewsc','normtime'}
                view_lf.plot_criteria_vs_order_vs_time(...
                    'criteria',p.Results.plot_crit,...
                    'orders',1:p.Results.order);
            case {'aic','sc','norm'}
                view_lf.plot_criteria_vs_order(...
                    'criteria',p.Results.plot_crit,...
                    'orders',1:p.Results.order);
        end
    end
end

%% plot criteria for best order across trials
if p.Results.plot
    view_lf = ViewLatticeFilter(lf_files,'labels',data_labels);
    view_lf.compute(crit_all);
    
    switch p.Results.plot_crit
        case {'ewaic','ewsc','normtime'}
            view_lf.plot_criteria_vs_order_vs_time(...
                'criteria',p.Results.plot_crit,...
                'orders',p.Results.plot_orders,...
                'file_list',1:length(lf_files));
        case {'aic','sc','norm'}
            view_lf.plot_criteria_vs_order(...
                'criteria',p.Results.plot_crit,...
                'orders',p.Results.plot_orders,...
                'file_list',1:length(lf_files));
    end
end

end