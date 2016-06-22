%% check_validation_results.m

test = false;

% code to run analysis pipeline
% run_lattice_svm
% pipeline.run();

% get pipeline
pipeline = build_pipeline_lattice_svm();

% select jobs based on filter params
brick_name = 'bricks.lattice_filter_sources';
brick_code = pipeline.get_brick_code(brick_name);
params_name = 'params_lf_MQRDLSL2_p10_l099_n400';
param_code = pipeline.get_params_code(brick_name,params_name);

% select feature validation jobs
brick_name = 'bricks.features_validate';
brick_code_desired = pipeline.get_brick_code(brick_name);

pattern = ['.+' brick_code param_code '.*' brick_code_desired '\d+\>'];
jobs = fieldnames(pipeline.pipeline);
job_idx = cellfun(@(x) ~isempty(regexp(x,pattern,'match')),jobs,'UniformOutput',true);
jobs_desired = jobs(job_idx);

for i=1:length(jobs_desired)
    
    % decrypt job code
    pattern = [brick_code_desired '\d+\>'];
    job_code = regexp(jobs_desired{i},pattern,'match');
    job_name = pipeline.expand_code(job_code{1},'expand','params');
    
    fprintf('%s\n',job_name);
    fprintf('%s\n',repmat('-',1,length(job_name)));
    
    % get the fm job
    %brick_name = 'bricks.features_fdr';
    %brick_code = pipeline.get_brick_code(brick_name);
    %pattern = ['(.*' brick_code '\d+)'];
    %job_fm = regexp(jobs_desired{i},pattern,'match');
    
    %file_features = pipeline.pipeline.(job_fm{1}).files_out;
    file_validated = pipeline.pipeline.(jobs_desired{i}).files_out;
    %fprintf('features: %s\nvalidated: %s\n',file_features,file_validated);
    
    % load the data
    %features = ftb.util.loadvar(file_features);
    if ~test
        validated = ftb.util.loadvar(file_validated);
        
        perf = svmmrmr_class_accuracy(...
            validated.class_labels, validated.predictions,...
            'verbosity',1);
        
        figure;
        plot_svmmrmr_confusion(validated.class_labels, validated.predictions);
    end
    
    fprintf('\n');
end