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

% set up bayes folder
bayes_dir = outdir;
if ~exist(bayes_dir,'dir')
    mkdir(bayes_dir);
end

files = [];
files.temp_log = [tempname '.log'];
files.temp_params = [tempname '.dat'];

files.log = fullfile(bayes_dir,'bayesopt.log');
files.params = fullfile(bayes_dir,'bayesopt.dat');

% check if the tune_file is fresh
if isfresh(files.params, tune_file)
    % delete the bayesopt params file
    delete(files.params);
end

% copy existing files to temp files
fields = {'log','params'};
for i=1:length(fields)
    field = fields{i};
    if exist(files.(field),'file')
        field_temp = ['temp_' field];
        copyfile(files.(field), files.(field_temp));
    end
end

params_bayes = [];
params_bayes.n_iterations = 10;
params_bayes.n_init_samples = 10;
params_bayes.verbose_level = 2; % 6 errors -> log file
params_bayes.log_filename = files.temp_log;
% params_file = 'bayesopt.dat';
if exist(files.params,'file')
    params_bayes.load_save_flag = 3;
    params_bayes.load_filename = files.temp_params;
    params_bayes.save_filename = files.temp_params;
else
    params_bayes.load_save_flag = 2;
    params_bayes.save_filename = files.temp_params;
end
[opt,y] = bayesoptcont(func_bayes, n, params_bayes, lb, ub);


% move temp files to proper location
fields = {'log','params'};
for i=1:length(fields)
    field = fields{i};
    field_temp = ['temp_' field];
    if exist(files.(field_temp),'file')
        movefile(files.(field_temp), files.(field));
    end
end

end