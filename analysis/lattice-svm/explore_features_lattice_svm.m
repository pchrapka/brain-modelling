function explore_features_lattice_svm(params_subject,filter_params)
%EXPLORE_FEATURES_LATTICE_SVM explores features selected by pipeline
%   EXPLORE_FEATURES_LATTICE_SVM(filter_params) explores features selected
%   by pipeline
%
%   Input
%   -----
%   params_subject (string)
%       parameter file name of subject data
%   filter_params (cell array)
%       array of parameter file names for bricks.lattice_filter_sources

p = inputParser();
p.addRequired('params_subject',@ischar);
p.addRequired('filter_params',@iscell);
p.parse(params_subject,filter_params);

test = false;

% get pipeline
pipeline = build_pipeline_lattice_svm(params_subject);

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
        
        file_feature = pipeline.pipeline.(jobs_desired{i}).files_in;
        file_validated = pipeline.pipeline.(jobs_desired{i}).files_out;
        fprintf('file: %s\n',file_validated);
        
        if ~test
            % load data
            validated = loadfile(file_validated);
            features = loadfile(file_feature);
            
            % select common features
            ncommon = 10;
            [feat_common, freq] = features_select_common(validated.feat_sel,ncommon);
            
            % select corresponding labels
            labels_mrmr = features.feature_labels(feat_common);
            
            fprintf(' Index     | Frequency | Label     \n');
            fprintf('-----------------------------------\n');
            for k=1:ncommon
                fprintf(' %9d | %9d | %s\n',feat_common(k), freq(k), labels_mrmr{k});
            end
        end
        
        fprintf('\n');
        
    end
end