function gamma_opt = tune_lattice_filter_gamma_bayesopt(tune_file,outdir,varargin)
%   Parameters
%   ----------
%   outdir
%       output directory for temp files, the name should reflect the
%       tune_file and the current filter parmeters
%   filter_params
%       requires the following fields: nchannels,norder,ntrials,lambda

p = inputParser();
p.StructExpand = false;
addRequired(p,'tune_file',@ischar);
addRequired(p,'outdir',@ischar);
addParameter(p,'filter','MCMTLOCCD_TWL4',@ischar);
addParameter(p,'filter_params',[],@isstruct);
default_gamma_exp = linspace(-14,2,10);
default_gamma = 10.^default_gamma_exp;
addParameter(p,'gamma',default_gamma,@isnumeric);
addParameter(p,'run_options',{},@iscell);
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
addParameter(p,'plot_gamma_fit',false,@islogical);
parse(p,tune_file,outdir,varargin{:});

% check filter_params
fields = {'nchannels','norder','ntrials','lambda'};
for i=1:length(fields)
    if ~isfield(p.Results.filter_params,fields{i})
        error([mfilename ':input'],'missing field %s in filter_params',fields{i});
    end
end

func_filter = str2func(p.Results.filter);
ngamma = length(p.Results.gamma);

filters = cell(ngamma,1);
for k=1:ngamma
    % TODO the parameter order here is specific to MCMTLOCCD_TWL4, it's ok for now
    filter_params = {...
        p.Results.filter_params.nchannels,...
        p.Results.filter_params.norder,...
        p.Results.filter_params.ntrials,...
        'lambda',p.Results.filter_params.lambda,...
        'gamma',p.Results.gamma(k)};
    filters{k} = func_filter(filter_params{:});
end

% separate outdir into a basedir and outdir
[basedir,outdir2,~] = fileparts([outdir '.m']);

% run filter
lf_files = run_lattice_filter(...
    tune_file,...
    'basedir',basedir,...
    'outdir',outdir2,... 
    'filters', filters,...
    p.Results.run_options{:},...
    'force',false,...
    'verbosity',0,...
    'tracefields', {'Kf','Kb','Rf','ferror','berrord'});

% evaluate criteria
view_lf = ViewLatticeFilter(lf_files);
criteria = {'normerrortime','norm1coefs_time'};
view_lf.compute(criteria);

crit_idx = p.Results.criteria_samples;
if isempty(crit_idx)
    % load one criteria to get samples
    crit_val = view_lf.get_criteria(...
        'criteria',criteria{1},...
        'orders',p.Results.filter_params.norder,...
        'file_list',1);
    nsamples = size(crit_val.f{1},2);
    
    % select all samples for mean
    crit_idx = [1 nsamples];
end

data = zeros(ngamma,length(criteria)+1);
data(:,3) = p.Results.gamma;

for j=1:length(criteria)
    % get criteria
    crit_val = view_lf.get_criteria(...
        'criteria',criteria{j},...
        'orders',p.Results.filter_params.norder,...
        'file_list',1:ngamma);
        
    for k=1:ngamma
        
        % take mean of forward
        crit_mean_f = mean(crit_val.f{k}(crit_idx(1):crit_idx(2)));
        % take mean of backward
        crit_mean_b = mean(crit_val.b{k}(crit_idx(1):crit_idx(2)));
        
        % data = [criteria1 criteria2 gamma]
        data(k,j) = crit_mean_f + crit_mean_b;
        
    end
end

% normalize data
data_norm = data(:,1:2);
data_norm = data_norm - repmat(min(data_norm),ngamma,1);
data_norm = data_norm./repmat(max(data_norm),ngamma,1);
data_norm = data_norm + 0.1*ones(ngamma,2);

% fit curve
% hyperbola_eqn = 'b/(a*(x-d))+c';
% start_points = [1 1 0 0];
% foptions = fitoptions('Method','NonlinearLeastSquares',...
%     'Lower',[0 0 -Inf -Inf],...
%     'Upper',[Inf,Inf,Inf,Inf],...
%     'StartPoint',start_points);
% ft = fittype(hyperbola_eqn,'options',foptions);

% gaussEqn = 'a*exp(-((x-b)/c)^2)+d';
% start_points = [1 0 1 0];
% foptions = fitoptions('Method','NonlinearLeastSquares',...
%     'Lower',[-Inf -Inf eps -Inf],...
%     'Upper',[Inf,Inf,Inf,Inf],...
%     'StartPoint',start_points);
% ft = fittype(gaussEqn,'options',foptions);
% 
% 
% curve = fit(data_norm(:,1), data_norm(:,2),ft);

curve = fit(data_norm(:,1), data_norm(:,2),'exp2');

% compute curvature
x_data = linspace(min(data_norm(:,1)),max(data_norm(:,1)),100);
[dy, dyy] = differentiate(curve, x_data);
K = abs(dyy)./((1+dy.^2).^(3/2));

% find max curvature
[K_max,K_idx] = max(K);

target_crit1_norm = x_data(K_idx);
range = max(data(:,1)) - min(data(:,1));
target_crit1 = (target_crit1_norm - 0.1)*range + min(data(:,1));

target_crit2_norm = curve(target_crit1_norm);
range = max(data(:,2)) - min(data(:,2));
target_crit2 = (target_crit2_norm - 0.1)*range + min(data(:,2));

if p.Results.plot_gamma_fit
    figure;
    subplot(2,2,1);
    plot(data(:,1),data(:,2));
    title('original data');
    
    
    subplot(2,2,2);
    plot(data_norm(:,1),data_norm(:,2));
    title('normalized data');
    
    subplot(2,2,3);
    plot(curve,data_norm(:,1),data_norm(:,2));
    title('fit to normalized data');
    
    subplot(2,2,4);
    plot(x_data,K);
    title('curvature');
    drawnow;
end

% return arg max gamma
filter_params = {...
        p.Results.filter_params.nchannels,...
        p.Results.filter_params.norder,...
        p.Results.filter_params.ntrials,...
        'lambda',p.Results.filter_params.lambda};
func_bayes = @(x) tune_lattice_filter(...
    tune_file,...
    outdir,...
    'filter',p.Results.filter,...
    'filter_params',[filter_params, 'gamma',x(1)],...
    'run_options',p.Results.run_options,...
    'criteria',criteria,...
    'criteria_mode','criteria_target',...
    'criteria_target',[target_crit1,target_crit2],...
    'criteria_samples',crit_idx);

ub = max(p.Results.gamma);
lb = 0;

gamma_opt = tune_lattice_filter_bayesopt(tune_file,outdir,func_bayes,1,lb,ub);
fprintf('set gamma to %g\n',gamma_opt);

end