function pdc_plot_seed_threshold(view_obj)

nchannels = length(view_obj.info.label);

directions = {'outgoing','incoming'};
for direc=1:length(directions)
    for ch=1:nchannels
        
        created = view_obj.plot_seed(ch,...
            'direction',directions{direc},...
            'threshold_mode','numeric',...
            'threshold',0.001,...
            'vertlines',[0 0.5]);
        
        if created
            view_obj.save_plot('save',true,'engine','matlab');
        end
        close(gcf);
    end
end

end