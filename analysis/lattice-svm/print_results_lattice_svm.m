function print_results_lattice_svm(filter_params)
%PRINT_RESULTS_LATTICE_SVM prints lattice svm pipeline results
%   PRINT_RESULTS_LATTICE_SVM(filter_params) prints lattice svm pipeline
%   results
%
%   Input
%   -----
%   filter_params (cell array)
%       array of parameter file names for bricks.lattice_filter_sources

p = inputParser();
addRequired(p,'filter_params',@iscell);
parse(p,filter_params);

test = false;

% get pipeline
pipeline = build_pipeline_lattice_svm();

for j=1:length(filter_params)
    fprintf('%s\n', filter_params{j});
    fprintf('%s\n\n',repmat('=',1,length(filter_params{j})));
    
    % select jobs based on filter params
    brick_name = 'bricks.lattice_filter_sources';
    brick_code = pipeline.get_brick_code(brick_name);
    param_code = pipeline.get_params_code(brick_name,filter_params{j});
    
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
        
        % get test job
        brick_name = 'bricks.train_test_common';
        brick_code_tt = pipeline.get_brick_code(brick_name);
        pattern = [jobs_desired{i} '.*' brick_code_tt '\d+\>'];
        job_idx = cellfun(@(x) ~isempty(regexp(x,pattern,'match')),jobs,'UniformOutput',true);
        job_test = jobs(job_idx);
        
        file_validated = pipeline.pipeline.(jobs_desired{i}).files_out;
        file_test = pipeline.pipeline.(job_test{1}).files_out;
        
        % load the data
        if ~test
            validated = ftb.util.loadvar(file_validated);
            
            perf = svmmrmr_class_accuracy(...
                validated.class_labels, validated.predictions,...
                'verbosity',1);
            
            figure;
            plot_svmmrmr_confusion(validated.class_labels, validated.predictions);
            
            fprintf('test:\n');
            test_result = ftb.util.loadvar(file_test);
            perf = svmmrmr_class_accuracy(...
                test_result.class_labels, test_result.predictions,...
                'verbosity',1);
        end
        
        fprintf('\n');
    end
end

end