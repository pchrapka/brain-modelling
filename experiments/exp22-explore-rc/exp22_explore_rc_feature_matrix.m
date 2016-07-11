%% exp22_explore_rc_feature_matrix

pipeline = build_pipeline_lattice_svm('params_sd_22_consec');

%% get codes for filter
filter_params = {...
    'params_lf_MQRDLSL2_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l09_n400',...
    ...'params_lf_MLOCCDTWL_p10_l099_n400',... % TODO
    ...'params_lf_MLOCCDTWL_p10_l098_n400',... % TODO
    };

for i=1:length(filter_params)
    % select jobs based on filter params
    brick_name = 'bricks.lattice_filter_sources';
    brick_code = pipeline.get_brick_code(brick_name);
    param_code = pipeline.get_params_code(brick_name,filter_params{i});
    
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
    
    h = figure('Position', [100, 100, 600, 800]);
    plot_rc_feature_matrix(data,'mode','mean');
    save_tag = strrep(['mean-' filter_params{i} '-' param_file],'_','-');
    save_fig_exp(mfilename('fullpath'),'tag',save_tag);
    close(h);
    
    h = figure('Position', [100, 100, 600, 800]);
    plot_rc_feature_matrix(data,'mode','median');
    save_tag = strrep(['median-' filter_params{i} '-' param_file],'_','-');
    save_fig_exp(mfilename('fullpath'),'tag',save_tag);
    close(h);
    
    h = figure('Position', [100, 100, 600, 800]);
    plot_rc_feature_matrix(data,'mode','std');
    save_tag = strrep(['std-' filter_params{i} '-' param_file],'_','-');
    save_fig_exp(mfilename('fullpath'),'tag',save_tag);
    close(h);
    
    h = figure('Position', [100, 100, 600, 800]);
    plot_rc_feature_matrix(data,'mode','diff-mean');
    save_tag = strrep(['diff-mean-' filter_params{i} '-' param_file],'_','-');
    save_fig_exp(mfilename('fullpath'),'tag',save_tag);
    close(h);
    
    h = figure('Position', [100, 100, 600, 800]);
    plot_rc_feature_matrix(data,'mode','diff-median');
    save_tag = strrep(['diff-median-' filter_params{i} '-' param_file],'_','-');
    save_fig_exp(mfilename('fullpath'),'tag',save_tag);
    close(h);
    
end

fprintf('Done\n');