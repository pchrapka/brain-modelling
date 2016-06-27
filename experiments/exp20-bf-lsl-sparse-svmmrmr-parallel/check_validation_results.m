%% check_validation_results.m

% code to run analysis pipeline
% run_lattice_svm
% pipeline.run();

params_subject = 'params_sd_22';
params_name = {'params_lf_MLOCCDTWL_p10_l099_n400'};

print_results_lattice_svm(params_subject,params_name,'tofile',true);
