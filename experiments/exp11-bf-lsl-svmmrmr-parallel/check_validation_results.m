%% check_validation_results.m

% code to run analysis pipeline
% run_lattice_svm
% pipeline.run();

params_name = {...
    'params_lf_MQRDLSL2_p10_l099_n400',...
    };

print_results_lattice_svm(params_name,'tofile',true);
