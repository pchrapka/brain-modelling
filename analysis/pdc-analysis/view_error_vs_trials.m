%% view_error_vs_trials

params = [];
params.patch_type = 'aal-coarse-19-outer-plus2';
params.ntrials = [20 40 60];
params.order = 3;
params.lambda = 0.99;
params.gamma = 1e-3;
params.normalization = 'allchannels';
params.envelope = true;

lf_files = cell(length(params.ntrials),1);
data_labels = lf_files;
for i=1:length(params.ntrials)
    
    stimulus = 'std';
    subject = 3;
    deviant_percent = 10;
    
    [pipeline,outdir] = eeg_processall_andrew(...
        stimulus,subject,deviant_percent,params.patch_type);
    
    % select lf params
    params_lf = copyfields(params,[],...
        {'ntrials','order','lambda','gamma','normalization','envelope'});
    params_lf.ntrials = params.ntrials(i);
    params_func = struct2namevalue(params_lf);
    
    lf_file = lf_analysis_main(pipeline, outdir, params_func{:});
    
    lf_files{i} = lf_file{1};
    data_labels{i} = sprintf('%d trials',params.ntrials(i));
    
end

%% plot prediction error

crit = 'normtime';

view_lf = ViewLatticeFilter(lf_files,'labels',data_labels);
view_lf.compute({crit});

view_lf.plot_criteria_vs_order_vs_time(...
    'criteria',crit,...
    'orders',params.order,...
    'file_list',1:length(lf_files));