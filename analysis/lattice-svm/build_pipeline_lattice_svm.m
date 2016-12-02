function pipeline = build_pipeline_lattice_svm(params_subject)
%BUILD_PIPELINE_LATTICE_SVM builds pipeline for the lattice filter SVM
%
%   NOTE: depends on output from exp10_beamform_patch
%
%   params_subject (string)
%       parameter file for subject data

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));
% pipeline folder
outdir = fullfile(srcdir,'output');

%% set up parallel pool
setup_parfor();

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
    'params_lf_MQRDLSL2_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt3_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt8_p10_l099_n400',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l098_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l098_n400',...
    'params_lf_MCMTQRDLSL1_mt2_p10_l09_n400',...
    'params_lf_MCMTQRDLSL1_mt5_p10_l09_n400',...
    'params_lf_MLOCCDTWL_p10_l099_n400',...
    'params_lf_MLOCCDTWL_p10_l098_n400',...
    'params_lf_MCMTLOCCDTWL2_mt5_p10_l099_n400',...
    'params_lf_MCMTLOCCDTWL2_mt5_p10_l098_n400',...
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
    job_al{i} = pipeline.add_job(name_brick, ...
        params_sd.conds(i).opt_func,...
        'files_in', params_sd.conds(i).file);
end

job_lf = cell(length(params_sd.conds),1);
for j=1:length(params_sd.analysis)
    for i=1:length(params_sd.conds)
        % add lattice filter sources
        name_brick = 'bricks.lattice_filter_sources';
        opt_func = params_sd.analysis(j).lf;
        job_lf{i} = pipeline.add_job(name_brick,...
            opt_func,'parent_job',job_al{i});
    end
    
    if ~isempty(params_sd.analysis(j).fm)
        % add feature matrix
        name_brick = 'bricks.features_matrix';
        opt_func = params_sd.analysis(j).fm;
        job_fm = pipeline.add_job(name_brick,opt_func,'parent_job',job_lf);
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
            pipeline.add_job(name_brick,opt_func,'parent_job',job_fv,...
                'partition_job', job_pt, 'fdr_job', job_fd_train);
        end
    else
        continue;
    end
    
end

% default pipeline options
pipeline.options.mode = 'session';
pipeline.options.max_queued = 1; % use one thread since all stages use parfor

end