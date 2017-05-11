function opt = tune_lattice_filter_bayesopt(tune_file,outdir,func_bayes,n,lb,ub,varargin)

p = inputParser();
p.StructExpand = false;
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addRequired(p,'func_bayes',@(x) isa(x,'function_handle'));
addRequired(p,'n',@isnumeric);
addRequired(p,'lb',@isnumeric);
addRequired(p,'ub',@isnumeric);
addParameter(p,'prevx',[],@isnumeric);
addParameter(p,'prevy',[],@isnumeric);
parse(p,tune_file,outdir,func_bayes,n,lb,ub,varargin{:});

if (isempty(p.Results.prevx) && ~isempty(p.Results.prevy)) || (~isempty(p.Results.prevx) && isempty(p.Results.prevy))
    error('both prevx and prevy need to be specified');
end

flag_bayes_create_params = false;
if ~isempty(p.Results.prevx) && ~isempty(p.Results.prevy)
    if length(p.Results.prevx) ~= length(p.Results.prevy)
        error('prevx and prevy are not the same legnth');
    end
    
    %flag_bayes_create_params = true;
    % NOTE I'm getting strange answers
end

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

% see if we should create a params file
if ~exist(files.params,'file') && flag_bayes_create_params
    bayes_create_params_file(files.params,p.Results.prevx,p.Results.prevy);
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
if ~flag_bayes_create_params
    params_bayes.n_init_samples = 10;
end

params_bayes.verbose_level = 2; % 6 errors -> log file
params_bayes.log_filename = files.temp_log;
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

function bayes_create_params_file(filename,prevx,prevy)
% generates parameter file for bayesopt, using default settings
% NOTE does not account for n > 1

fid = fopen(filename,'w+');
if fid == -1
    error('could not open file %s',filename);
end

ndata = length(prevx);

if ndata < 10
    warning('using less than 10 samples to initialize bayesopt');
end

fprintf(fid,'mCurrentIter=0\n');
fprintf(fid,'mCounterStuck=0\n');
fprintf(fid,'mYPrev=%0.9f\n',max(prevy));
fprintf(fid,'mParameters.n_iterations=10\n');
fprintf(fid,'mParameters.n_inner_iterations=500\n');
fprintf(fid,'mParameters.n_init_samples=%d\n',ndata);
fprintf(fid,'mParameters.n_iter_relearn=50\n');
fprintf(fid,'mParameters.init_method=1\n');
fprintf(fid,'mParameters.surr_name=sGaussianProcess\n');
fprintf(fid,'mParameters.sigma_s=1\n');
fprintf(fid,'mParameters.noise=1e-06\n');
fprintf(fid,'mParameters.alpha=1\n');
fprintf(fid,'mParameters.beta=1\n');
fprintf(fid,'mParameters.sc_type=SC_MAP\n');
fprintf(fid,'mParameters.l_type=L_EMPIRICAL\n');
fprintf(fid,'mParameters.l_all=0\n');
fprintf(fid,'mParameters.epsilon=0\n');
fprintf(fid,'mParameters.force_jump=20\n');
fprintf(fid,'mParameters.kernel.name=kMaternARD5\n');
fprintf(fid,'mParameters.kernel.hp_mean=[1](1)\n');
fprintf(fid,'mParameters.kernel.hp_std=[1](10)\n');
fprintf(fid,'mParameters.mean.name=mConst\n');
fprintf(fid,'mParameters.mean.coef_mean=[1](1)\n');
fprintf(fid,'mParameters.mean.coef_std=[1](1000)\n');
fprintf(fid,'mParameters.crit_name=cEI\n');
fprintf(fid,'mParameters.crit_params=[0]()\n');
fprintf(fid,'mY=[%d](',ndata);
for i=1:ndata
    fprintf(fid,'%0.9f',prevy(i));
    if i ~= ndata
        fprintf(fid,',');
    end
end
fprintf(fid,')\n');
fprintf(fid,'mX=[%d,1](',ndata);
for i=1:ndata
    fprintf(fid,'%0.9f',prevx(i));
    if i ~= ndata
        fprintf(fid,',');
    end
end
fprintf(fid,')\n');

fclose(fid);
end