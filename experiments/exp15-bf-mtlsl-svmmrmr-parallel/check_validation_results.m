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

print_results_lattice_svm(params_name);