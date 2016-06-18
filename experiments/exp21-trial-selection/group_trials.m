function group_trials(files_in, files_out, opt)
%   Group trials into cross validation and test sets

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% pipeline folder
outdir = fullfile(srcdir,'output','lattice-svm');

% subject specific info
[~,subject_file,subject_name] = get_coma_data(22);

pipedir = fullfile(outdir,subject_name);

% params
% - output path, specific to data set
% - # of cv trials and # of test set trials
% - for each source analysis data set: select_trials options, in and output
% files

% add select trials
name_brick = 'bricks.select_trials';
opt_func = 'params_st_std_100_consec';
files_in = fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat');
[~,job_std] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);

opt_func = 'params_st_odd_100_consec';
files_in = fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/sourceanalysis.mat');
[~,job_odd] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);

for i=1:nlabels
    
    bricks.select_trials(files_in, files_out, {'trials', ?, 'label', labels{i}, 'mode', 'consecutive'});
    
end
end