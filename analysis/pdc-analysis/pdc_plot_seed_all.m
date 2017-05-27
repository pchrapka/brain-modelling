function pdc_plot_seed_all(view_obj,varargin)

nchannels = length(view_obj.info.label);

directions = {'outgoing','incoming'};
for direc=1:length(directions)
    params_plot = [varargin, {'direction',directions{direc}}];
    for ch=1:nchannels
        
        % get the save tag only
        view_obj.plot_seed(ch,...
            params_plot{:},...
            'get_save_tag',true);
        [outdir, outfile] = view_obj.get_fullsavefile();
        
        file_name_date = datestr(now, 'yyyy-mm-dd');
        if exist(fullfile([outdir '/img'],[file_name_date '-' outfile '.eps']),'file')
            fprintf('%s: skipping %s\n',mfilename,outfile);
            continue;
        end
        
        % plot for reals
        created = view_obj.plot_seed(ch,...
            params_plot{:});
        
        if created
            view_obj.save_plot('save',true,'engine','matlab');
        end
        close(gcf);
    end
end

end