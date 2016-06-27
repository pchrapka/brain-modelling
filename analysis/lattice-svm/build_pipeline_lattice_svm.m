function pipeline = build_pipeline_lattice_svm()
%BUILD_PIPELINE_LATTICE_SVM builds pipeline for the lattice filter SVM
%analysis of P022 data
%
%   NOTE: depends on output from exp10_beamform_patch

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));
% pipeline folder
outdir = fullfile(srcdir,'output');

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

f = 1;
params_filter = [];
params_filter(f).params_filter = 'params_lf_MQRDLSL2_p10_l099_n400';
params_filter(f).params_partition = 'params_pf_std_odd_tr100_te20';
f = f+1;
params_filter(f).params_filter = 'params_lf_MLOCCDTWL_p10_l099_n400';
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

f = 1;
feat_options(f).fv = 'params_fv_rbf_20';
feat_options(f).tt = 'params_tt_rbf_10';
f = f+1;
feat_options(f).fv = 'params_fv_rbf_40';
feat_options(f).tt = 'params_tt_rbf_20';
f = f+1;
feat_options(f).fv = 'params_fv_rbf_60';
feat_options(f).tt = 'params_tt_rbf_30';
f = f+1;
feat_options(f).fv = 'params_fv_rbf_100';
feat_options(f).tt = 'params_tt_rbf_50';
f = f+1;
% feat_options(f).fv = 'params_fv_rbf_1000';
% feat_options(f).tt = 'params_tt_rbf_500';
% f = f+1;
% feat_options(f).fv = 'params_fv_rbf_2000';
% feat_options(f).tt = 'params_tt_rbf_1000';
% f = f+1;
% feat_options(f).fv = 'params_fv_rbf_10000';
% feat_options(f).tt = 'params_tt_rbf_5000';
% f = f+1;

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
    name_brick = 'bricks.features_matrix';
    opt_func = 'params_fm_lattice_train';
    job_fm_train = pipeline.add_job(name_brick,opt_func,'parent_job',job_pt);
    
    % add feature matrix for test data
    name_brick = 'bricks.features_matrix';
    opt_func = 'params_fm_lattice_test';
    job_fm_test = pipeline.add_job(name_brick,opt_func,'parent_job',job_pt);
    
    % add feature matrix
    name_brick = 'bricks.features_fdr';
    opt_func = 'params_fd_20000';
    job_fd_train = pipeline.add_job(name_brick,opt_func,'parent_job',job_fm_train);
    
    for k=1:length(feat_options)
        % add feature validation
        name_brick = 'bricks.features_validate';
        opt_func = feat_options(k).fv;
        job_fv = pipeline.add_job(name_brick,opt_func,'parent_job',job_fd_train);
        
        % add train test
        name_brick = 'bricks.train_test_common';
        opt_func = feat_options(k).tt;
        pipeline.add_job(name_brick,opt_func,'parent_job',job_fv,...
            'test_job', job_fm_test, 'train_job', job_fm_train, 'fdr_job', job_fd_train);
    end
    
end

% pipeline options
pipeline.options.mode = 'session';
pipeline.options.max_queued = 1; % use one thread since all stages use parfor

end