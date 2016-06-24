%% check_validation_results.m

test = false;

% code to run analysis pipeline
% run_lattice_svm
% pipeline.run();

% get pipeline
pipeline = build_pipeline_lattice_svm();

params_name = {...
    'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400',...
    };

for j=1:length(params_name)
    fprintf('%s\n', params_name{j});
    fprintf('%s\n\n',repmat('=',1,length(params_name{j})));
    
    % select jobs based on filter params
    brick_name = 'bricks.lattice_filter_sources';
    brick_code = pipeline.get_brick_code(brick_name);
    param_code = pipeline.get_params_code(brick_name,params_name{j});
    
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
        %features = ftb.util.loadvar(file_features);
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
                test_data.class_labels, test_results.predictions,...
                'verbosity',1);
        end
        
        fprintf('\n');
    end
end