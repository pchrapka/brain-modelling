function pipeline = build_pipeline_lattice_svm(params_subject,varargin)
%BUILD_PIPELINE_LATTICE_SVM builds pipeline for the lattice filter SVM
%
%   NOTE: depends on output from exp10_beamform_patch
%
%   params_subject (string)
%       parameter file for subject data
%
%   Parameters
%   ----------
%   mode (default = 'session')
%       pipeline operation mode, options: session, batch
%       batch is useful for doing filtering in parallel
%       session is better for svm portion

p = inputParser();
addRequired(p,'params_subject',@ischar);
addParameter(p,'mode','session',@(x) any(validatestring(x,{'session','batch'})));
parse(p,params_subject,varargin{:});

switch p.Results.mode
    case 'batch'
        % only runs labeling and filtering in batch mode
        fprintf('warning:\n');
        fprintf([...
            'batch mode only runs labeling and filtering jobs.\n'...
            'this is to run those jobs in parallel on the first\n'...
            'run of the pipeline. the remainder of the jobs can be\n'...
            'run with the session option.\n']);
        response = input('Continue? (y)','s');
        if isequal(response,'y') || isequal(response,'Y')
        else
            fprintf('stopping\n');
            pipeline = [];
            return;
        end
end

parfor_close();

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));
% pipeline folder
outdir = fullfile(srcdir,'output');

%% subject specific data

params_func = str2func(params_subject);
params_sd = params_func();

%% create lattice filter pipeline

pipedir = fullfile(outdir,params_subject);
pipeline = PipelineLatticeSVM(pipedir);

%% add available params
% why? so that the indexing is static between pipeline initializations

params_setup = [];
f=1;
params_setup(f).brick = 'bricks.add_label';
params_setup(f).param_files = {...
    'params_al_odd',...
    'params_al_std',...
    };
f = f+1;
params_setup(f).brick = 'bricks.lattice_filter_sources';
params_setup(f).param_files = {...
    'params_lf_MQRDLSL2_p10_l099',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l099',...
    'params_lf_MCMTQRDLSL1_mt3_p10_l099',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l099',...
    'params_lf_MCMTQRDLSL1_mt8_p10_l099',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l098',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l098',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l09',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l09',...
    'params_lf_MLOCCDTWL_p10_l099',...
    'params_lf_MLOCCDTWL_p10_l099_g16',...
    'params_lf_MLOCCDTWL_p10_l098',...
    'params_lf_MLOCCDTWL_p10_l098_g16',...
    'params_lf_MCMTLOCCDTWL2_mt5_p10_l099',...
    'params_lf_MCMTLOCCDTWL2_mt5_p10_l099_g28',...
    'params_lf_MCMTLOCCDTWL2_mt5_p10_l098',...
    'params_lf_MCMTLOCCDTWL2_mt5_p10_l098_g28',...
    };
f = f+1;
params_setup(f).brick = 'bricks.features_matrix';
params_setup(f).param_files = {...
    'params_fm_lattice_thresh1dot5',...
    'params_fm_lattice_nothresh',...
    'params_fm_lattice_nothresh_scalefw',...
    'params_fm_lattice_thresh1dot5clamp',...
    };
f = f+1;
params_setup(f).brick = 'bricks.features_validate';
params_setup(f).param_files = {...
    'params_fv_rbf_20',...
    'params_fv_rbf_40',...
    'params_fv_rbf_60',...
    'params_fv_rbf_100',...
    'params_fv_rbf_1000',...
    'params_fv_rbf_2000',...
    'params_fv_rbf_10000',...
    };
f = f+1;
params_setup(f).brick = 'bricks.partition_data';
params_setup(f).param_files = {...
    'params_pd_std_odd_tr100_te20',...
    'params_pd_std_odd_tr70_te20',...
    'params_pd_std_odd_tr30_te20',...
    'params_pd_std_odd_tr20_te10',...
    };
f = f+1;
params_setup(f).brick = 'bricks.features_fdr';
params_setup(f).param_files = {...
    'params_fd_20000',...
    };
f = f+1;
params_setup(f).brick = 'bricks.train_test_common';
params_setup(f).param_files = {...
    'params_tt_rbf_10',...
    'params_tt_rbf_20',...
    'params_tt_rbf_30',...
    'params_tt_rbf_50',...
    'params_tt_rbf_500',...
    'params_tt_rbf_1000',...
    'params_tt_rbf_5000',...
    };
f = f+1;

for i=1:length(params_setup)
    for j=1:length(params_setup(i).param_files)
        pipeline.add_params(params_setup(i).brick, params_setup(i).param_files{j});
    end
end

%% add jobs to pipeline

job_al = cell(length(params_sd.conds),1);
for i=1:length(params_sd.conds)
    % add data label
    name_brick = 'bricks.add_label';
    for j=1:length(params_sd.conds(i).trials)
        job_al{i,j} = pipeline.add_job(name_brick, ...
            params_sd.conds(i).opt_func,...
            'files_in', params_sd.conds(i).trials(j).file,'id',j);
        
        % set restart if the flag is set
        if params_sd.conds(i).trials(j).restart
            pipeline.options.restart{end+1} = job_al{i,j};
            pipeline.options.type_restart = 'substring';
        end
    end
end

job_lf = cell(length(params_sd.conds),1);
for j=1:length(params_sd.analysis)
    for i=1:length(params_sd.conds)
        % add lattice filter sources
        name_brick = 'bricks.lattice_filter_sources';
        opt_func = params_sd.analysis(j).lf;
        
        % parse inputs to get number of filter trials
        opt = feval(opt_func);
        ptemp = inputParser();
        ptemp.KeepUnmatched = true;
        addParameter(ptemp,'trials',1,@isnumeric);
        parse(ptemp,opt{:});
        ntrials_filter = ptemp.Results.trials;
        
        % group data based on filter size
        ntrials_data = length(params_sd.conds(i).trials);
        ntrial_groups = floor(ntrials_data/ntrials_filter);
        
        job_groups = reshape(job_al(i,:), ntrials_filter, ntrial_groups)';
        job_groups_shifted = circshift(job_groups,1);
        
        % set up job params
        for k=1:ntrial_groups
            job_lf{i,k} = pipeline.add_job(name_brick, opt_func,...
                'parent_job',job_groups(k,:),... %for job naming
                'parent_job_data',job_groups(k,:),...
                'parent_job_warmup',job_groups_shifted(k,:),...
                'id',k);
        end
    end
    
    if ~isempty(params_sd.analysis(j).fm)
        % add feature matrix
        name_brick = 'bricks.features_matrix';
        opt_func = params_sd.analysis(j).fm;
        job_fm = pipeline.add_job(name_brick,opt_func,'parent_job',job_lf(:));
    else
        continue;
    end
    
    if ~isempty(params_sd.analysis(j).pd)
        % add select trials
        name_brick = 'bricks.partition_data';
        opt_func = params_sd.analysis(j).pd;
        % NOTE don't add parent job here, just make a not in opt_func
        job_pt = pipeline.add_job(name_brick,opt_func,'parent_job',job_fm);
    else
        continue;
    end
    
    if ~isempty(params_sd.analysis(j).fd)
        % add feature selection fdr
        name_brick = 'bricks.features_fdr';
        opt_func = params_sd.analysis(j).fd;
        job_fd_train = pipeline.add_job(name_brick,opt_func,'parent_job',job_pt);
    else
        continue;
    end
    
    if ~isempty(params_sd.analysis(j).fv)
        for k=1:length(params_sd.analysis(j).fv)
            % add feature validation
            name_brick = 'bricks.features_validate';
            opt_func = params_sd.analysis(j).fv{k};
            job_fv = pipeline.add_job(name_brick,opt_func,'parent_job',job_fd_train);
            
            % add train test
            name_brick = 'bricks.train_test_common';
            opt_func = params_sd.analysis(j).tt{k};
            pipeline.add_job(name_brick,opt_func,...
                'parent_job',job_fv,... % input and job code naming
                'partition_job', job_pt, 'fdr_job', job_fd_train);
        end
    else
        continue;
    end
    
end

% default pipeline options
switch p.Results.mode
    case 'batch'
        % NOTE i'm assuming i'm starting in the right directory
        pipeline.options.init_matlab = 'if ~exist(''VRC'',''file''), startup; end';
        pipeline.options.mode = 'batch';
        switch get_compname()
            case {sprintf('blade16.ece.mcmaster.ca\n'),'blade16.ece.mcmaster.ca'}
                pipeline.options.max_queued = 22;
            otherwise
                pipeline.options.max_queued = 1;
        end
    case 'session'
        parfor_setup();
        pipeline.options.mode = 'session';
        pipeline.options.max_queued = 1;
    otherwise
        error('unknown mode');
end

% restart the whole pipeline if the restart flag is set
% Only the case if the initial data changes
if isfield(params_sd,'restart')
    if params_sd.restart
        pipeline.options.restart = 'al';
        pipeline.options.type_restart = 'substring';
    end
end

%% save pipeline
outfile = fullfile(pipedir,'pipeline.mat');
save(outfile,'pipeline');

end
