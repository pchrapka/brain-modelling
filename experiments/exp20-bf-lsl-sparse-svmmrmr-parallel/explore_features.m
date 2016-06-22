%% explore_features

test = false;

% code to run analysis pipeline
% run_lattice_svm
% pipeline.run();

% get pipeline
pipeline = build_pipeline_lattice_svm();

% select jobs based on filter params
brick_name = 'bricks.lattice_filter_sources';
brick_code = pipeline.get_brick_code(brick_name);
params_name = 'params_lf_MLOCCDTWL_p10_l099_n400';
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
    
    file_validated = pipeline.pipeline.(jobs_desired{i}).files_out;
    fprintf('file: %s\n',file_validated);
    
    if ~test
        % load data
        din = load(file_validated);
        
        % select common features
        ncommon = 10;
        [feat_common, freq] = features_select_common(din.data.feat_sel,ncommon);
        
        % select corresponding labels
        labels_mrmr = din.data.class_labels(feat_common);
        
        fprintf(' Index     | Frequency | Label     \n');
        fprintf('-----------------------------------\n');
        for j=1:ncommon
            fprintf(' %9d | %9d | %s\n',feat_common(j), freq(j), labels_mrmr{j});
        end
    end
    
    fprintf('\n');
    
end