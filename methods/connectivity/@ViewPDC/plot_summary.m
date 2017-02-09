function plot_summary(obj)

obj.save_tag = [];
obj.load();

[~,nchannels,~,nfreqs]=size(obj.pdc);
    
w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

data_plot = zeros(nchannels, nchannels);
for j=1:nchannels
    for i=1:nchannels
        % data
        if j ~= i
            
            data_temp = abs(squeeze(obj.pdc(:,i,j,freq_idx))');
            
            data_plot(j,i) = sum(data_temp(:));
        end
        
    end
end

title('PDC - Channel Pair Summary');
imagesc(data_plot);
colorbar();
xlabel('Channels');
ylabel('Channels');

ticks = 1:nchannels;
if isempty(obj.labels)
    tick_labels = cell(nchannels,1);
    for i=1:nchannels
        tick_labels{i} = num2str(i);
    end
    set(gca,...
        'Xtick',ticks,...
        'XtickLabel',tick_labels,...
        'Ytick',ticks,...
        'YtickLabel',tick_labels);
else
    set(gca,...
        'Xtick',ticks,...
        'XtickLabel',obj.labels,...
        'Ytick',ticks,...
        'YtickLabel',obj.labels);
end

obj.save_tag = '-pdc-dynamic-summary';

end