%% paper_plot_surrogate_hist

dir_data = fullfile('home-old','chrapkpk','Documents','projects',...
    'analysis','pdc-analysis','output','std-s03-10-old',...
    'aal-coarse-19-outer-nocer-hemileft-audr2-v1r2',...
    'lf-dta-trialsall-samplesall-normeachchannel-envyes-prependflipdata',...
    'MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-bootstrap-estimate_ind_channels',...
    'bootstrap-by-samples','pdc-dynamic-diag-f512-ds4');
file_data = 'sample257-n100.mat'; % use time = 0

file_name = fullfile(dir_data,file_data);

data = loadfile(file_name);
[nresample,nchannels,~,nfreq] = size(data);

bins = 1:19;
bins = bins/20;

figure;
for row=1:nchannels
    for col=1:nchannels
        plot_idx = (row-1)*nchannels + col;
        subaxis(nchannels, nchannels, plot_idx,...
            'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.1);
        hist(squeeze(data(:,row,col,:)),bins);
        
        if col == 1 && row == 1
            title(sprintf('freq normalized (0-0.5) %0.4f',(f-1)/nfreq*0.5));
        end
        
        if col==1
            ylabel(sprintf('ch %d',row));
        end
        
        if row==nchannels
            xlabel(sprintf('ch %d',col));
        end
        
        if col ~= 1
            set(gca,'YTick',[]);
            set(gca,'YTickLabel',[]);
        end
        
        if row ~= nchannels
            set(gca,'XTick',[]);
            set(gca,'XTickLabel',[]);
        end
        
    end
end