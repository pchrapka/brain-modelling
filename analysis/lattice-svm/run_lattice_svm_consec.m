%% run_lattice_svm_consec
% Goal:
%   Run lattice svm alg on P022 data, depends on output from
%   exp10_beamform_patch

pipeline = build_pipeline_lattice_svm('params_sd_22_consec');

% pipeline options
pipeline.options.mode = 'session';
pipeline.options.max_queued = 1; % use one thread since all stages use parfor

% pipeline.run();


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