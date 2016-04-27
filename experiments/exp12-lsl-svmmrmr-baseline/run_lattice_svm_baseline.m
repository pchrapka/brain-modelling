%% run_lattice_svm_baseline
% Goal:
%   Run lattice svm alg on baseline VAR data sets

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% pipeline folder
outdir = fullfile(srcdir,'output','lattice-svm-baseline');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% set up test data
cond_labels = {'std','odd'};
ncond = length(cond_labels);
for i=1:ncond
    cond_files{i} = fullfile(outdir,sprintf('%s.mat',cond_labels{i}));
end
ntrials = 100;
nsources = 13;
ntime = 100;
order = 8;
for i=1:ncond
    % check if the data file exists
    if ~exist(cond_files{i},'file')
        % set up VAR model with random coefficients
        s = VAR(nsources, order);
        s.coefs_gen();
%         switch i
%             case 1
%                 % set up VAR model with random coefficients
%                 s = VAR(nsources, order);
%                 s.coefs_gen();
%             case 2
%                 % set up VAR model with specific coefficients
%             otherwise
%                 error('too many conditions');
%         end
%         
        data = [];
        data(ntrials).inside = [];
        for j=1:ntrials
            % simulate process
            [~,signal_norm,~] = s.simulate(2*ntime);
            
            data(j).label = cond_labels{i};
            data(j).inside = ones(nsources,1);
            data(j).avg.mom = cell(nsources,1);
            data(j).time = linspace(-0.5,1,ntime);
            for k=1:nsources
                data(j).avg.mom{k} = signal_norm(k,ntime+1:end); %[1 time]
            end
        end
        save(cond_files{i},'data');
    else
        fprintf('data exists\n');
    end
end

%% set up parallel pool
setup_parfor();

%% set up pipeline

pipedir = outdir;
pipeline = PipelineLatticeSVM(pipedir);

% add select trials
name_brick = 'bricks.select_trials';
opt_func = 'params_st_std_100';
files_in = cond_files{1};
[~,job_std] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);
opt_func = 'params_st_odd_100';
files_in = cond_files{2};
[~,job_odd] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);

% add lattice filter sources
name_brick = 'bricks.lattice_filter_sources';
opt_func = 'params_lf_1';
files_in = [pipeline.pipeline.(job_std).files_out; pipeline.pipeline.(job_odd).files_out];
[~,job_name] = pipeline.add_job(name_brick,opt_func,'files_in',files_in);

% add feature matrix
name_brick = 'bricks.lattice_features_matrix';
opt_func = 'params_fm_1';
prev_job = job_name;
[~,job_name] = pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

% add feature validation
name_brick = 'bricks.features_validate';
opt_func = 'params_fv_100';
prev_job = job_name;
[~,job_name] = pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

opt_func = 'params_fv_1000';
[~,job_name] = pipeline.add_job(name_brick,opt_func,'prev_job',prev_job);

% pipeline options
pipeline.options.path_logs = fullfile(pipedir, 'logs');
pipeline.options.mode = 'background';
% pipeline.options.mode = 'session';
pipeline.options.max_queued = 1; % use one thread since all stages use parfor

pipeline.run();

%%%%%%%%%%%%%%%%%%%%%%%%
%% Monitor pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%

%% Display flowchart
% psom_pipeline_visu(pipeline.options.path_logs,'flowchart');

%% List the finished jobs
% psom_pipeline_visu(pipeline.options.path_logs,'finished');

%% Display log
% psom_pipeline_visu(pipeline.options.path_logs,'log','quadratic');

%% Display Computation time
% psom_pipeline_visu(pipeline.options.path_logs,'time','');

%% Monitor history
% psom_pipeline_visu(pipeline.options.path_logs,'monitor');