%% run_lattice_svm
%
%   Usage:
%
%   Example:
%   pipeline = build_pipeline_lattice_svm('params_sd_22');
%
%   Available options
%   P022 data, all trials, depends on output from exp10_beamform_patch
%   pipeline = build_pipeline_lattice_svm('params_sd_22');
%
%   P022 data, consecutive std odd trials, depends on output from exp10_beamform_patch
%   pipeline = build_pipeline_lattice_svm('params_sd_22_consec');
%
%   simulated VAR
%   pipeline = build_pipeline_lattice_svm('params_sd_var_p8_ch13');

% Goal:
%   Run lattice svm alg

% P022 data, all trials, depends on output from exp10_beamform_patch
% pipeline = build_pipeline_lattice_svm('params_sd_22');

% P022 data, consecutive std odd trials, depends on output from exp10_beamform_patch
% pipeline = build_pipeline_lattice_svm('params_sd_22_consec');

% simulated VAR
% pipeline = build_pipeline_lattice_svm('params_sd_var_p8_ch13');

%%%%%%%%%%%
%% Usage %%
%%%%%%%%%%%

%% Run pipeline
% pipeline.run();

%% Monitor pipeline 

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