%% test_run_lattice_svm
% Goal:
%   Test parallel setup for lattice svm alg

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% pipeline folder
outdir = fullfile(srcdir,'output','lattice-svm-test');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% set up test data
ncond = 2;
cond_labels = {'std','odd'};
ntrials = 10;
nsources = 13;
ntime = 100;
for i=1:ncond
    data = [];
    data(ntrials).inside = [];
    for j=1:ntrials
        data(j).label = cond_labels{i};
        data(j).inside = ones(nsources,1);
        data(j).avg.mom = cell(nsources,1);
        data(j).time = linspace(-0.5,1,ntime);
        for k=1:nsources
            data(j).avg.mom{k} = rand(1,ntime);
        end
    end
    save(fullfile(outdir,sprintf('%s.mat',cond_labels{i})),'data');
end


%% set up parallel pool
setup_parfor();

%% set up pipeline

pipedir = outdir;
pipeline = PipelineLatticeSVM(pipedir);

% add select trials
name_brick = 'bricks.select_trials';
opt_func = 'params_st_std_10';
[~,job_std] = pipeline.add_job(name_brick,opt_func,'files_in',fullfile(outdir,'std.mat'));
opt_func = 'params_st_odd_10';
[~,job_odd] = pipeline.add_job(name_brick,opt_func,'files_in',fullfile(outdir,'odd.mat'));

% add lattice filter sources
name_brick = 'bricks.lattice_filter_sources';
opt_func = 'params_lf_p10_l099';
files_in = [pipeline.pipeline.(job_std).files_out; pipeline.pipeline.(job_odd).files_out];
[~,job_name] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);

% add feature matrix
name_brick = 'bricks.lattice_features_matrix';
opt_func = 'params_fm_test';
prev_job = job_name;
[~,job_name] = pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

% add feature validation
name_brick = 'bricks.features_validate';
opt_func = 'params_fv_100';
prev_job = job_name;
[~,job_name] = pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

% pipeline options
pipeline.options.path_logs = fullfile(pipedir, 'logs');
pipeline.options.mode = 'session';
pipeline.options.restart = 'st3fm_params_fm_test';
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