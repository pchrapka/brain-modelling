function lattice_filter_perf(data_path, varargin)
%   Input
%   -----
%   data_path (string)
%       path for filtered data

%% parse inputs
p = inputParser();
addRequired(p,'data_path',@ischar);
p.parse(data_path,varargin{:});

%% get true data

% get parameters
pattern = '(params_sd_[\d\w_]*)';
out = regexp(data_path,pattern,'tokens');
data_name = out{1}{1};

fh = str2func(data_name);
params = fh('mode','short');

% figure out which label
pattern = 'al-([\d\w]*)';
out = regexp(data_path,pattern,'tokens');
data_label = out{1}{1};

idx = 0;
for i=1:length(params.conds)
    if isequal(data_label,params.conds(i).label)
        idx = i;
        break;
    end
end

% load true coefficients
datafile_true = params.var_gen(idx).get_file();
data_true = loadfile(datafile_true);

truth = data_true.process.Kf;

%% get filtered data
pattern = fullfile(data_path,'lattice-filtered-id*.mat');
result = dir(pattern);

% prep truth
datafile = fullfile(data_path,result(1).name);
data = loadfile(datafile);
nsamples = size(data.Kf,1);
truth_mat = repmat(shiftdim(truth,-1),[nsamples,1,1,1]);

% allocate mem
ntrials = length(result);
data_mse = zeros(ntrials,1);

% for each filtered trial
for i=1:ntrials
    datafile = fullfile(data_path,result(i).name);
    data = loadfile(datafile);
    
    % take nmse over all coefficients and all trials
    data_mse(i) = nmse(data.Kf(:), truth_mat(:));
end

%% plot

% get filter name
pattern = 'lf-([\d\w-]*)';
out = regexp(data_path,pattern,'tokens');
slug_filter = out{1}{1};
filter_name = strrep(slug_filter,'-',' ');

% plot
h = figure;
scatter(1:ntrials,db(data_mse,'power'),'filled');
ylim([10^(-4) 10^(0)]);
title(sprintf('NMSE over Trials: %s',filter_name));
xlabel('Trials');
ylabel('NMSE (dB)');

%% save fig

% create img dir
outdir = fullfile(data_path,'img');
if ~exist(outdir,'dir');
    mkdir(outdir);
end

% save dated and tagged file
drawnow;
save_fig_exp(outdir,...
    'tag',sprintf('nmse-%s',slug_filter));
close(h);

end