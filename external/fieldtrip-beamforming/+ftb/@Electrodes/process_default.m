function obj = process_default(obj)

if obj.check_file(obj.elec_aligned)
    % load electrodes
    elec = ftb.util.loadvar(obj.elec);
    % align electrodes
    data = ft_electroderealign(obj.config.ft_electroderealign, elec);
    save(obj.elec_aligned, 'data');
else
    fprintf('%s: skipping ft_electroderealign, already exists\n',mfilename);
end

endrt