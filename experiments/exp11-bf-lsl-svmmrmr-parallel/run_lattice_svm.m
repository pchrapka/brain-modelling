%% run_lattice_svm
% Goal:
%   Run lattice svm alg on P022 data, depends on output from
%   exp10_beamform_patch

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% pipeline folder
outdir = fullfile(srcdir,'output','lattice-svm');

% subject specific info
[~,subject_file,subject_name] = get_coma_data(22);

%% set up parallel pool
setup_parfor();

%% set up pipeline

pipedir = fullfile(outdir,subject_name);
pipeline = PipelineLatticeSVM(pipedir);

% TODO in beamforming step select only consecutive std dev pairs

% add select trials
name_brick = 'bricks.select_trials';
opt_func = 'params_st_std_100';
files_in = fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat');
[~,job_std] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);
opt_func = 'params_st_odd_100';
files_in = fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat');
[~,job_odd] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);

% add lattice filter sources
name_brick = 'bricks.lattice_filter_sources';
opt_func = 'params_lf_p10_l099';
files_in = [pipeline.pipeline.(job_std).files_out; pipeline.pipeline.(job_odd).files_out];
[~,job_name] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);

% add feature matrix
name_brick = 'bricks.lattice_features_matrix';
opt_func = 'params_fm_1';
prev_job = job_name;
[~,job_name] = pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

ft_options = {...
    'params_fv_20',...
    'params_fv_40',...
    'params_fv_60',...
    'params_fv_100',...
    ...'params_fv_1000',...
    ...'params_fv_2000',...
    ...'params_fv_10000',...
    };

prev_job = job_name;
for j=1:length(ft_options)
    % add feature validation
    name_brick = 'bricks.features_validate';
    opt_func = ft_options{j};
    pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);
end
% params_fv_20
% approx. 57%
% runtime: 0.54 hours

% params_fv_40
% approx. 60%
% runtime: 0.74 hours

% params_fv_60
% approx. 61%
% runtime: 0.93 hours

% params_fv_100
% approx. 63%
% runtime: 1.8 hours

% params_fv_1000
% approx. 78%
% runtime: 26 hours

% params_fv_2000
% approx. 80.5%
% runtime: 54 hours

% params_fv_10000
% approx. 83%
% runtime: approx. 7-9 days on 10 cores

% pipeline options
pipeline.options.path_logs = fullfile(pipedir, 'logs');
pipeline.options.mode = 'session';
% NOTE other modes don't seem to work well, i think i might need proper
% project and parfor setup code in each function
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