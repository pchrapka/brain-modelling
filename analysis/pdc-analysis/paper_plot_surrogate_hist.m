%% paper_plot_surrogate_hist

params = data_beta_config();
dir_root = params.data_dir;
dir_data = fullfile(dir_root,'output','std-s03-10',...
    'aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata');
% dir_surrogate = fullfile(dir_data,...
%     'MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-surrogate-estimate_ind_channels');
slug_filter = 'MCMTLOCCD_TWL4-T20-C7-P4-lambda0.9900-gamma1.000e-05-p3';

% surrogate_type = 'ind';
surrogate_type = 'ns';

switch surrogate_type
    case 'ind'
        dir_surrogate = fullfile(dir_data,...
            [slug_filter '-removed-surrogate-estimate_ind_channels']);
    case 'ns'
        dir_surrogate = fullfile(dir_data,...
            [slug_filter '-removed-surrogate-estimate_stationary_ns']);
    otherwise
        error('unknown surrogate type')
end
file_name_surrogate = fullfile(dir_surrogate,...
    'pdc-dynamic-diag-f2048-41-ds4-sig-n100-alpha0.05.mat');

% get sample,row,col idx with largest gPDC threshold
data = loadfile(file_name_surrogate);
data_temp = data.pdc;
samples_remove = 256;
data_temp(1:samples_remove,:,:,:) = [];
% max over freqs
data_temp = max(data_temp, [], 4);
% max over samples
[data_temp, idx_samples] = max(data_temp);
idx_samples = squeeze(idx_samples);
data_temp = squeeze(data_temp);
% remove diagonals
n = size(data_temp,1);
data_temp(logical(true(n).*eye(n))) = 0;
% get max in matrix
[~,idx] = max(data_temp(:));
[idx_row, idx_col] = ind2sub(size(data_temp), idx);
idx_sample = idx_samples(idx_row, idx_col);

%%
file_data = sprintf('sample%d-n100.mat',idx_sample+samples_remove); % use time = 0
dir_samples = fullfile(dir_surrogate,...
    'surrogate-by-samples','pdc-dynamic-diag-f2048-41-ds4');
file_name = fullfile(dir_samples,file_data);

data = loadfile(file_name);
[nresample,nchannels,~,nfreqs] = size(data);

file_info = fullfile(dir_data,'..',...
    'sources-info.mat');
info = loadfile(file_info);

% plot_type = 'tiled';
plot_type = 'single';

%% sort channels
patch_info = ChannelInfo(info.labels);
patch_type = 'aal-coarse-19';
patch_info.populate(patch_type);

[~,idx_sorted] = sort(patch_info.region_order);
labels = info.labels(idx_sorted);
data = data(:,idx_sorted,idx_sorted,:);

%% select freqs

f = (0:nfreqs-1)/(2*nfreqs);
f = f*info.fsample;
freq_max = 10;
idx_freq = f <= freq_max;
% idx_freq(1) = false;
data = data(:,:,:,idx_freq);

%%
% nbins = 20;
nbins = 100;
bins = 1:nbins-1;
bins = bins/nbins;

figure('Color','white');
font_size = 14;

switch plot_type
    case 'single'
        %row = 2;
        %col = 4;
        set(gca,'FontSize',font_size);
        data_temp = squeeze(data(:,idx_row,idx_col,:));
        hist(data_temp(:),bins);
        title(sprintf('%s to %s',labels{idx_col}, labels{idx_row}));
        ylabel('Number of gPDC values');
        xlabel('gPDC value');
        
        outfile = ['surrogate-hist-' surrogate_type '-' strrep(file_data,'.mat','')...
            sprintf('-row%d-col%d',idx_row,idx_col)];
        
    case 'tiled'
        for row_idx=1:nchannels+2
            for col_idx=1:nchannels+1
                plot_idx = (row_idx-1)*(nchannels+1) + col_idx;
                subaxis(nchannels+2, nchannels+1, plot_idx,...
                    'Spacing', 0.02, 'SpacingVert', 0.02, 'Padding', 0, 'Margin', 0.1);
                set(gca,'FontSize',font_size);
                col = col_idx - 1;
                row = row_idx;
                
                if (col_idx == 1) || (row_idx > nchannels)
                    axis('off')
                    %             if row_idx == nchannels+1
                    %                 scale = 0.9;
                    %                 pos = get(gca, 'Position');
                    %                 pos(2) = pos(2)-scale*pos(4);
                    %                 %pos(4) = (1-scale)*pos(4);
                    %                 pos(4) = 4*pos(4);
                    %                 set(gca, 'Position', pos)
                    %             end
                    continue;
                end
                
                if row ~= col
                    data_temp = squeeze(data(:,row,col,:));
                    hist(data_temp(:),bins);
                else
                    set(gca,'Color','white');
                end
                
                if col==1
                    ylabel(labels{row},'Rotation',0,'HorizontalAlignment','Right');
                end
                
                if row==nchannels
                    xlabel(labels{col},'Rotation',90,'HorizontalAlignment','Right');
                end
                
                %if col ~= 1
                set(gca,'YTick',[]);
                set(gca,'YTickLabel',[]);
                %end
                
                if row < nchannels
                    set(gca,'XTick',[]);
                    set(gca,'XTickLabel',[]);
                end
                
            end
        end
        
        outfile = ['surrogate-hist-' surrogate_type '-' strrep(file_data,'.mat','')];
    otherwise
        error('unknown plot_type %s',plot_type);
end

%% save
outdir = fullfile('output');
save_fig2('path',outdir,'tag', outfile,'engine','matlab');
