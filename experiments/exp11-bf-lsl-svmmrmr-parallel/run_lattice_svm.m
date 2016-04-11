%% run_lattice_svm
% Goal:
%   Run lattice svm alg on P022 data, depends on output from exp10_beamform_patch

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% pipeline folder
outdir = fullfile(srcdir,'output','lattice-svm');

% subject folder
subject_file = 'BC.HC.YOUTH.P022-9913';
subject_dir = strrep(subject_file,'BC.HC.YOUTH.','');

%% set up parallel pool
% TODO

%% set up pipeline

pipedir = fullfile(outdir,subject_dir);
pipeline = PipelineLatticeSVM(pipedir);

% add select trials
name_brick = 'bricks.select_trials';
opt_func = 'params_st_1';
trial_list = {...
    fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat'),...
    fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat'),...
    };

% NOTE trial_list order matters, should follow labels in params
pipeline.add_job(name_brick,opt_func,'trial_list',trial_list);

% add lattice filter sources
name_brick = 'bricks.lattice_filter_sources';
opt_func = 'params_lf_1';
prev_job = pipeline.last_job();
pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

% add feature matrix
name_brick = 'bricks.lattice_features_matrix';
opt_func = 'params_fm_1';
prev_job = pipeline.last_job();
pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

% add feature validation
name_brick = 'bricks.features_validate';
opt_func = 'params_fv_1';
prev_job = pipeline.last_job();
pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

% pipeline options
obj.pipeline_options.path_logs = fullfile(pipedir, 'logs');
obj.pipeline_options.mode = 'background';
obj.pipeline_options.max_queued = 1; % use one thread since all stages use parfor

pipeline.run();

%%%%%%%%%%%%%%%%%%%%%%%%
%% Monitor pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%

%% Display flowchart
% psom_pipeline_visu(obj.pipeline_options.path_logs,'flowchart');

%% List the finished jobs
% psom_pipeline_visu(obj.pipeline_options.path_logs,'finished');

%% Display log
% psom_pipeline_visu(obj.pipeline_options.path_logs,'log','quadratic');

%% Display Computation time
% psom_pipeline_visu(obj.pipeline_options.path_logs,'time','');

%% Monitor history
% psom_pipeline_visu(obj.pipeline_options.path_logs,'monitor');