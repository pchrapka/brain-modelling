function obj = process_default(obj)

if obj.check_file(obj.elec_aligned)
    % load electrodes
    elec = ftb.util.loadvar(obj.elec);
    % align electrodes
    elec = ft_electroderealign(obj.config.ft_electroderealign, elec);
    
    % Convert units
    if isfield(obj.config,'units')
        fprintf('%s: converting units to %s\n',...
            strrep(class(obj),'ftb.',''), obj.config.units);
        elec = ft_convert_units(elec, obj.config.units);
    end
    
    if isfield(obj.config.ft_channelselection)
        fprintf('%s: selecting channels\n',...
            strrep(class(obj),'ftb.',''));
        
        channels = ft_channelselection(obj.config.ft_channelselection,elec.label);
        [~, channel_idx] = match_str(channels, elec.label);
        
        % select wanted channels
        elec.chanpos = elec.chanpos(channel_idx,:);
        elec.elecpos = elec.elecpos(channel_idx,:);
        elec.label = elec.label(channel_idx);
    end
    
    % NOTE needs to be saved as elec in mat file, fieldtrip quirk
    save(obj.elec_aligned, 'elec');
else
    fprintf('%s: skipping ft_electroderealign, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end