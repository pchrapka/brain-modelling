%% exp22_explore_rc

pipeline = build_pipeline_lattice_svm('params_sd_22');

% filter_params = 'params_lf_MQRDLSL2_p10_l099_n400';
filter_params = 'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400';

% select jobs based on filter params
brick_name = 'bricks.lattice_filter_sources';
brick_code = pipeline.get_brick_code(brick_name);
param_code = pipeline.get_params_code(brick_name,filter_params);

pattern = ['.+' brick_code param_code '\>'];
jobs = fieldnames(pipeline.pipeline);
job_idx = cellfun(@(x) ~isempty(regexp(x,pattern,'match')),jobs,'UniformOutput',true);
jobs_desired = jobs(job_idx);

% load file list of filtered data
file_filtered_data = pipeline.pipeline.(jobs_desired{1}).files_out;
filtered_list = ftb.util.loadvar(file_filtered_data);

% select a few
nfiles = 3;
filtered_list = filtered_list(1:3);

comp_name = get_compname();
% mode = 'image-all';
% mode = 'image-order';
% mode = 'image-max';
% mode = 'movie-order';
mode = 'movie-max';
figure;

for i=1:1%length(filtered_list)
    if ~isempty(strfind(comp_name,'Valentina'))
        % replace the root dir depending on the comp we're using
        filtered_list{i} = strrep(filtered_list{i},...
            get_root_dir('blade16.ece.mcmaster.ca'),...
            get_root_dir('Valentina'));
    end
    data = ftb.util.loadvar(filtered_list{i});
    
    % TODO do stuff
    plot_rc(data,'mode',mode);
end