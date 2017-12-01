function plot_pdc_distr_with_surrogate_threshold(file_name_std,file_name_mean,varargin)

p = inputParser();
p.StructExpand = false;
addRequired(p,'file_name_std',@ischar);
addRequired(p,'file_name_mean',@ischar);
addParameter(p,'surrogate_files',{},@iscell);
addParameter(p,'surrogate_legend',{},@iscell);
addParameter(p,'freq_step',1,@isscalar);
addParameter(p,'freq_max',[],@isscalar);
addParameter(p,'idx_sample',1,@isscalar);
addParameter(p,'idx_channel_in',1,@isscalar);
addParameter(p,'idx_channel_out',1,@isscalar);
addParameter(p,'tag','notag',@ischar);
parse(p,file_name_std,file_name_mean,varargin{:});

idx_sample = p.Results.idx_sample;
idx_channel_in = p.Results.idx_channel_in;
idx_channel_out = p.Results.idx_channel_out;

data_std = loadfile(file_name_std);
data_std_sample = squeeze(data_std.pdc_std(idx_sample,idx_channel_in,idx_channel_out,:));
data_mean = loadfile(file_name_mean);
data_mean_sample = squeeze(data_mean.pdc_mean(idx_sample,idx_channel_in,idx_channel_out,:));

nsurrogates = length(p.Results.surrogate_files);
data_sur = cell(nsurrogates,1);
data_sur_sample = cell(nsurrogates,1);
for i=1:nsurrogates
    data_sur{i} = loadfile(p.Results.surrogate_files{i});
    data_sur_sample{i} = squeeze(data_sur{i}.pdc(idx_sample,idx_channel_in,idx_channel_out,:));
end

% TODO add freq_min
% or freq range
freq_step = p.Results.freq_step;
if isempty(p.Results.freq_max)
    nfreqs = size(data_std_sample,4);
    freq_max = (nfreqs-1)*freq_step;
else
    freq_max = p.Results.freq_max;
end
% freq_step = 0.5;
% freq_max = 10;
f = 0:freq_step:freq_max;
nfreqs_sel = length(f);
idx_freq = 1:nfreqs_sel;

figure;
legend_str = {};
hold on;
h(1) = plot(f,data_mean_sample(idx_freq),'k-');
legend_str = [legend_str {'mean'}];

h(2) = plot(f,data_mean_sample(idx_freq) + data_std_sample(idx_freq),'k:');
plot(f,data_mean_sample(idx_freq) - data_std_sample(idx_freq),'k:');
legend_str = [legend_str {'+/- 1 standard deviation'}];

count = 3;
lines = {'-.','--'};
for i=1:nsurrogates
    h(count) = plot(f,data_sur_sample{i}(idx_freq),['k' lines{i}]);
    if isempty(p.Results.surrogate_legend{i})
        legend_str = [legend_str {'surrogate ' num2str(i)}];
    else
        legend_str = [legend_str p.Results.surrogate_legend(i)];
    end
    count = count + 1;
end

% legend(h,{'mean','+/- 1 standard deviation','threshold - stationary','threshold - no coupling'});
legend(h,legend_str);
ylim([0 1]);
ylabel('gPDC');
xlabel('Frequency');

% save
outfile = sprintf('pdc-distr-with-surrogate-thresh-%s-in%d-out%d-sample%d',...
    p.Results.tag,idx_channel_in,idx_channel_out,idx_sample);
outdir = fullfile('output');
save_fig2('path',outdir,'tag', outfile,'engine','matlab');
end