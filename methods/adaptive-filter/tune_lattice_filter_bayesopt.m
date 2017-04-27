function opt = tune_lattice_filter_bayesopt(tune_file,outdir,func_bayes,n,lb,ub)

p = inputParser();
p.StructExpand = false;
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addRequired(p,'func_bayes',@(x) isa(x,'function_handle'));
addRequired(p,'n',@isnumeric);
addRequired(p,'lb',@isnumeric);
addRequired(p,'ub',@isnumeric);
parse(p,tune_file,outdir,func_bayes,n,lb,ub);

[~,datadir,~] = fileparts(tune_file);
bayes_dir = fullfile(outdir,datadir);
if ~exist(bayes_dir,'dir')
    mkdir(bayes_dir);
end

params_bayes = [];
params_bayes.n_iterations = 10;
params_bayes.n_init_samples = 10;
params_bayes.verbose_level = 2; % 6 errors -> log file
params_bayes.log_filename = fullfile(bayes_dir,'bayesopt.log');
params_file = fullfile(bayes_dir,'bayesopt.dat');
% if exist(params_file,'file')
%     params_bayes.load_save_flag = 3;
%     params_bayes.load_filename = params_file;
% else
    params_bayes.load_save_flag = 2;
    params_bayes.save_filename = params_file;
% end
[opt,y] = bayesoptcont(func_bayes, n, params_bayes, lb, ub);

end