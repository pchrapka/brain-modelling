%% paper_plot_surrogate_hist

dir_root = fullfile('/home.old','chrapkpk','Documents','projects','brain-modelling',...
    'analysis','pdc-analysis','output','std-s03-10-old',...
    'aal-coarse-19-outer-nocer-hemileft-audr2-v1r2');
dir_data = fullfile(dir_root,...
    'lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata',...
    'MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-surrogate-estimate_ind_channels',...
    'surrogate-by-samples','pdc-dynamic-diag-f512-ds4');
file_data = 'sample257-n100.mat'; % use time = 0

file_name = fullfile(dir_data,file_data);

data = loadfile(file_name);
[nresample,nchannels,~,nfreqs] = size(data);

dir_root2 = strrep(dir_root,'home.old','home-new');
file_info = fullfile(dir_root2,'sources-info.mat');
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
idx_freq = f <= 5;
% idx_freq(1) = false;
data = data(:,:,:,idx_freq);

%%
nbins = 20;
bins = 1:nbins-1;
bins = bins/nbins;

figure('Color','white');
font_size = 14;

switch plot_type
    case 'single'
        row = 2;
        col = 4;
        set(gca,'FontSize',font_size);
        data_temp = squeeze(data(:,row,col,:));
        hist(data_temp(:),bins);
        ylabel(labels{row});%,'Rotation',0,'HorizontalAlignment','Right');
        xlabel(labels{col});%,'Rotation',90,'HorizontalAlignment','Right');
        
        outfile = ['surrogate-hist-' strrep(file_data,'.mat','')...
            sprintf('-row%d-col%d',row,col)];
        
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
        
        outfile = ['surrogate-hist-' strrep(file_data,'.mat','')];
    otherwise
        error('unknown plot_type %s',plot_type);
end

%% save
outdir = fullfile('output');
save_fig2('path',outdir,'tag', outfile,'engine','matlab');
