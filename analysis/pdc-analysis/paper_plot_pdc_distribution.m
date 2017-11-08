%% paper_plot_pdc_distribution

params = data_beta_config();
dir_root = params.data_dir;
% '/home.old','chrapkpk','Documents','projects','brain-modelling','analysis','pdc-analysis',

dir_data = fullfile(dir_root,'output','std-s03-10',...
    'aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata');

% get data size
file_data = 'MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4.mat';
file_name = fullfile(dir_data,file_data);
data = loadfile(file_name);
[nsamples,nchannels,~,nfreqs] = size(data.pdc);

idx_channel_in = 1; % temporal
idx_channel_out = 6; % auditory
idx_sample = 656;

% get sample idx with largest gPDC
% data_temp = squeeze(data.pdc(:,idx_channel_in,idx_channel_out,:));
% [val,idx] = max(data_temp);

npermutations = 100;
data_hist = zeros(npermutations,nfreqs);
for i=1:npermutations
    fprintf('working on permutation %d\n',i);
    
    % set up data file
    file_data = sprintf('MCMTLOCCD_TWL4-T100-C7-P5-lambda0.9900-gamma1.000e-05-p%d-removed-pdc-dynamic-diag-f2048-41-ds4.mat',i);    
    file_name = fullfile(dir_data,file_data);
    
    % load data
    data = loadfile(file_name);
    
    data_hist(i,:) = squeeze(data.pdc(idx_sample,idx_channel_in,idx_channel_out,:));
    
end

freq_step = 0.5;
freq_max = 10;
f = linspace(0,freq_max,freq_max/freq_step+1);
nfreqs_sel = length(f);
idx_freq = 1:nfreqs_sel;

nbins = 20;
bins = linspace(0,1,nbins+1);
bins = bins + bins(2);
bins = bins(1:nbins-1);
Z = [];
for i=1:nfreqs_sel
    Z(i,:) = hist(data_hist(idx_freq,i),bins);
end
b = bar3(1:nfreqs_sel,Z);
for i=1:length(b)
    b(i).CData = b(i).ZData;
    b(i).FaceColor = 'interp';
end
set(gca,'XTick',downsample(1:nbins-1,2));
set(gca,'XTickLabel',downsample(bins,2));
xlabel('gPDC');

set(gca,'YTick',downsample(idx_freq,2));
set(gca,'YTickLabel',downsample(f,2));
ylabel('Frequency');