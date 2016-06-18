%% test_merge_pipeline
%   Goal:
%       Test if you can combine two psom pipelines and reuse the output for
%       a common job
%
%   Conclusion:
%       The only way not to redo computations is to have one pipeline

clear all;

%% set up job 1
pipeline1 = [];
job1 = 'st1';
opt1 = [];
job_name1 = [job1 '_' opt1];
outdir1 = [job1 '_' opt1];
pipeline1 = psom_add_job(pipeline1,job_name1,'test_create_data',...
    [],fullfile(outdir1,'input.mat'),opt1,false);

%% set up job 2 which depends on job 1
pipeline2 = [];
job2 = 'st2';
opt2 = 'params_test';
job_name2 = [job_name1 '_' job2 '_' opt2];
outdir2 = fullfile(outdir1,[job2 '_' opt2]);
pipeline2 = psom_add_job(pipeline2,job_name2,'test_bash_func',...
    fullfile(outdir1,'input.mat'),fullfile(outdir2,'output.mat'),opt2,false);

% merge job 1 and job 2
pipeline12 = psom_merge_pipeline(pipeline1,pipeline2);

% run merged pipeline
options = [];
% options.path_logs = fullfile(outdir2,'logs');
options.path_logs = 'logs';
options.mode = 'session';
options.max_queued = 1;

psom_run_pipeline(pipeline12,options);

%% set up job 3 which also depends on job 1
pipeline3 = [];
job3 = 'st2';
opt3 = 'params_test_2';
job_name3 = [job_name1 '_' job3 '_' opt3];
outdir3 = fullfile(outdir1,[job3 '_' opt3]);
pipeline3 = psom_add_job(pipeline3,job_name3,'test_bash_func',...
    fullfile(outdir1,'input.mat'),fullfile(outdir3,'output.mat'),opt3,false);

% merge job 1 and job 3
pipeline13 = psom_merge_pipeline(pipeline12,pipeline3);

options = [];
% options.path_logs = fullfile(outdir3,'logs');
options.path_logs = 'logs';
options.mode = 'session';
options.max_queued = 1;

% run merged pipeline
psom_run_pipeline(pipeline13,options);