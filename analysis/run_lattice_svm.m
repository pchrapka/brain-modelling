%% run_lattice_svm
% Goal:
%   Run lattice svm alg on P022 data, depends on output from
%   exp10_beamform_patch

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));
% pipeline folder
outdir = fullfile(srcdir,'output','lattice-filter');

%% set up parallel pool
setup_parfor();

%% subject specific data
params_sd = params_sd_22();
% subject specific info
[~,subject_file,subject_name] = get_coma_data(params_sd.subject_id);

%% set up lattice filter pipeline

pipedir = fullfile(outdir,subject_name);
pipeline = PipelineLatticeSVM(pipedir);

% TODO in beamforming step select only consecutive std dev pairs

job_al = cell(length(params_sd.conds),1);
for i=1:length(params_sd.conds)
    % add data label
    name_brick = 'bricks.add_label';
    job_al{i} = pipeline.add_job(name_brick, ...
        params_sd.conds(i).opt_func,...
        'files_in', params_sd.conds(i).file);
end

% TODO 'params_lf_MLOCCD_TWL_p10_l099_n400'
f = 1;
params_filter = [];
params_filter(f).params_filter = 'params_lf_MQRDLSL2_p10_l099_n400';
params_filter(f).params_partition = 'params_pf_std_odd_tr100_te20';
f = f+1;
params_filter(f).params_filter = 'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400';
params_filter(f).params_partition = 'params_pf_std_odd_tr100_te20';
f = f+1;
params_filter(f).params_filter = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';
params_filter(f).params_partition = 'params_pf_std_odd_tr70_te20';
f = f+1;
params_filter(f).params_filter = 'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400';
params_filter(f).params_partition = 'params_pf_std_odd_tr30_te20';
f = f+1;
params_filter(f).params_filter = 'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400';
params_filter(f).params_partition = 'params_pf_std_odd_tr20_te10';
f = f+1;

job_lf = cell(length(params_sd.conds),1);
for j=1:length(params_filter)
    for i=1:length(params_sd.conds)
        % add lattice filter sources
        name_brick = 'bricks.lattice_filter_sources';
        opt_func = params_filter(j).params_filter;
        job_lf{i} = pipeline.add_job(name_brick,...
            opt_func,'parent_job',job_al{i});
    end
    
    % add select trials
    name_brick = 'bricks.partition_files';
    opt_func = params_filter(j).params_partition;
    % NOTE don't add parent job here, just make a not in opt_func
    job_pt = pipeline.add_job(name_brick,opt_func,'parent_job',job_lf);
    
    % add feature matrix
    name_brick = 'bricks.lattice_features_matrix';
    opt_func = 'params_fm_1';
    job_fm = pipeline.add_job(name_brick,opt_func,'parent_job',job_pt);
    
    ft_options = {...
        'params_fv_20',...
        'params_fv_40',...
        'params_fv_60',...
        'params_fv_100',...
        ...'params_fv_1000',...
        ...'params_fv_2000',...
        ...'params_fv_10000',...
        };
    
    for k=1:length(ft_options)
        % add feature validation
        name_brick = 'bricks.features_validate';
        opt_func = ft_options{k};
        job_fv = pipeline.add_job(name_brick,opt_func,'parent_job',job_fm);
        
        % TODO add new brick
%         name_brick = 'bricks.train_test';
%         opt_func = 'params_tt_1'; % not sure what options i'd need
%         pipeline.add_job(name_brick,opt_func,'parent_job',job_fv,'partition_job',job_pt);
    end
    
end

% pipeline options
pipeline.options.mode = 'session';
pipeline.options.max_queued = 1; % use one thread since all stages use parfor

pipeline.run();


%%%%%%%%%%%%%%%%%%%%%%%%
%% Monitor pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%

%% Display flowchart
% psom_pipeline_visu(pipeline.options.path_logs,'flowchart');

%% List the finished jobs
% psom_pipeline_visu(pipeline.options.path_logs,'finished');

%% Display log
% psom_pipeline_visu(pipeline.options.path_logs,'log','quadratic');

%% Display Computation time
% psom_pipeline_visu(pipeline.options.path_logs,'time','');

%% Monitor history
% psom_pipeline_visu(pipeline.options.path_logs,'monitor');