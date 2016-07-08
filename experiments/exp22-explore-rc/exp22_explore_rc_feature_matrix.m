%% exp22_explore_rc_feature_matrix

pipeline = build_pipeline_lattice_svm('params_sd_22_consec');

%% get codes for filter
filter_params = 'params_lf_MQRDLSL2_p10_l099_n400';
% filter_params = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';

% select jobs based on filter params
brick_name = 'bricks.lattice_filter_sources';
brick_code = pipeline.get_brick_code(brick_name);
param_code = pipeline.get_params_code(brick_name,filter_params);

param_file = 'params_fm_lattice_nothresh';

% select feature matrix jobs
brick_name = 'bricks.features_matrix';
brick_code_desired = pipeline.get_brick_code(brick_name);
param_code_desired = pipeline.get_params_code(brick_name,param_file);

%% get desired jobs
pattern = ['.+' brick_code param_code '.*' brick_code_desired param_code_desired '\>'];
jobs = fieldnames(pipeline.pipeline);
job_idx = cellfun(@(x) ~isempty(regexp(x,pattern,'match')),jobs,'UniformOutput',true);
jobs_desired = jobs(job_idx);

if length(jobs_desired) > 1
    fprintf('found more than one job\n');
    disp(jobs_desired);
end

%%

% load feature matrix
file_name = pipeline.pipeline.(jobs_desired{1}).files_out;
data = loadfile(file_name);

%%
% plot data
% plot_rc_feature_matrix(data,'mode','boxplot','interactive',true); % TMI
figure;
plot_rc_feature_matrix(data,'mode','mean');

figure;
plot_rc_feature_matrix(data,'mode','std');

figure;
plot_rc_feature_matrix(data,'mode','mean-diff');

% %%
% % load file list of filtered data
% file_filtered_data = pipeline.pipeline.(jobs_desired{1}).files_out;
% filtered_list = loadfile(file_filtered_data);
% 
% % select a few
% nfiles = 3;
% filtered_list = filtered_list(1:3);
% 
% comp_name = get_compname();
% % mode = 'image-all';
% % mode = 'image-order';
% % mode = 'image-max';
% % mode = 'movie-order';
% mode = 'movie-max';
% figure;
% 
% for i=1:1%length(filtered_list)
%     if ~isempty(strfind(comp_name,'Valentina'))
%         % replace the root dir depending on the comp we're using
%         filtered_list{i} = strrep(filtered_list{i},...
%             get_root_dir('blade16.ece.mcmaster.ca'),...
%             get_root_dir('Valentina'));
%     end
%     data = loadfile(filtered_list{i});
%     
%     % TODO do stuff
%     plot_rc(data,'mode',mode);
% end