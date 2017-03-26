function plot_tiled(obj)

obj.save_tag = [];
obj.load('pdc');
obj.check_info();

[~,nchannels,~,nfreqs]=size(obj.pdc);

obj.fs = p.Results.fs;
    
w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);
nPlotPoints = length(freq_idx);

hylabel = 0;
hxlabel = 0;

nticks = 6;
ytick = linspace(1, nPlotPoints, nticks);
yticklabel = cell(nticks,1);
for i=1:nticks
    yticklabel{i} = '';
end
yticklabel{1} = sprintf('%0.2f',obj.w(1)*obj.fs);
yticklabel{nticks} = sprintf('%0.2f',obj.w(2)*obj.fs);

h = [];

for j=1:nchannels
    for i=1:nchannels
        % data
        if j ~= i
            h = subplot2(nchannels, nchannels, (i-1)*nchannels + j);
            
            data_plot = abs(squeeze(obj.pdc(:,i,j,freq_idx))');
            
            clim = [0 1];
            imagesc(data_plot,clim);
        end
        
        % axis label
        if i == nchannels,
            if j == 1,
               hylabel(i) = obj.labelity(i);
               hxlabel(j) = obj.labelitx(j);
               
               set(h,...
                   'YTick', ytick, ...
                   'YTickLabel', yticklabel,...
                   'FontSize',10);
            else
                hxlabel(j) = obj.labelitx(j);
                set(h,...
                    'YtickLabel', []);
            end;
        elseif i == 1 && j == 2
            hylabel(i)=obj.labelity(i);
            set(h,...
                'XtickLabel', [],...
                'YtickLabel', []);
        elseif i == (nchannels-1) && j == nchannels
            hxlabel(j)=obj.labelitx(j);
            set(h,...
                'XtickLabel', [],...
                'YtickLabel', []);
        elseif j == 1,
            hylabel(i) = obj.labelity(i);
            set(h,...
                'XtickLabel', [],...
                'YTick', ytick, ...
                'YTickLabel', yticklabel,...
                'FontSize',10);
            if i == nchannels,
                set(h,'FontSize',10,'FontWeight','bold');
            end;
        else
            set(h,...
                'XtickLabel', [],...
                'YtickLabel', []);
        end;
    end
end

obj.save_tag = '-tiled';

end