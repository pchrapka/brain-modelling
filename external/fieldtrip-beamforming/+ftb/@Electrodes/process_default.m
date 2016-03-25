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
    
    % NOTE needs to be saved as elec in mat file, fieldtrip quirk
    save(obj.elec_aligned, 'elec');
else
    fprintf('%s: skipping ft_electroderealign, already exists\n',...
        strrep(class(obj),'ftb.',''));
end

end