function tune_model_order(pipeline,outdir,varargin)

p = inputParser();
addRequired(p,'pipeline',@(x) isa(x,'ftb.AnalysisBeamformer'));
addRequired(p,'outdir',@ischar);
addParameter(p,'patch_type','aal',@ischar);
addParameter(p,'ntrials',10,@isnumeric);
addParameter(p,'order',1:14,@(x) isnumeric(x) && isvector(x));
addParameter(p,'lambda',0.99,@(x) isnumeric(x) && length(x) == 1);
addParameter(p,'gamma',1e-2,@(x) isnumeric(x) && length(x) == 1);
addParameter(p,'normalization','allchannels',@ischar); % also none
addParameter(p,'envelope',false,@islogical); % also none
addParameter(p,'plot',true,@islogical);
addParameter(p,'plot_crit','ewaic',@ischar);
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

filters = {};
k = 1;

% tuning over model order
order_max = max(p.Results.order);
filters{k} = MCMTLOCCD_TWL4(nchannels,order_max,p.Results.ntrials,...
    'lambda',p.Results.lambda,'gamma',p.Results.gamma);
k = k+1;

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

%% set up view lattice
if p.Results.plot
    view_lf = ViewLatticeFilter(lf_files{1});
    crit_time = {'ewaic','ewsc','normtime'};
    crit_single = {'aic','sc','norm'};
    view_lf.compute([crit_time crit_single]);
    
    % plot order vs estimation error
    switch p.Results.plot_crit
        case {'ewaic','ewsc','normtime'}
            view_lf.plot_criteria_vs_order_vs_time(...
                'criteria',p.Results.plot_crit,'orders',p.Results.plot_orders);
        case {'aic','sc','norm'}
            view_lf.plot_criteria_vs_order(...
                'criteria',p.Results.plot_crit,'orders',p.Results.plot_orders);
    end
end

end