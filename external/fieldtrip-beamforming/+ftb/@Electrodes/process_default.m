function obj = process_default(obj)

if obj.check_file(obj.elec_aligned)
    % load electrodes
    elec = ftb.util.loadvar(obj.elec);
    % align electrodes
    elec = ft_electroderealign(obj.config.ft_electroderealign, elec);
    % NOTE needs to be saved as elec in mat file, fieldtrip quirk
    save(obj.elec_aligned, 'elec');
else
    fprintf('%s: skipping ft_electroderealign, already exists\n',mfilename);
end

end