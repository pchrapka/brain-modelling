function pipeline_group_trials(param_func)

if ischar(param_func)
    % get params
    params = feval(param_func);
else
    error('not sure what to do');
end

% set up pipeline
pipeline = PipelineLatticeSVM(params.pipeline.dir);

files_out = {};

% add select trials jobs
name_brick = 'bricks.select_trials';
for i=1:length(params.labels)
    opt_func = params.labels(i).opt_func;
    files_in = params.labels(i).files_in;
    [~,job_name] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);
    
    % save list of output files
    files_out = [files_out pipeline.pipeline(job_name).files_out];
    
    % TODO group into cross validation and test sets
    % TODO also consider situation with multiple trials
    % TODO also consider putting the current code into
    % pipline_select_trials
end

% set pipeline options
pipeline.options = params.pipeline.options;
% run the pipeline
pipeline.run();

% save output files
outfile = fullfile(params.pipeline.dir,'files_out.mat');
save(outfile, 'files_out');

end