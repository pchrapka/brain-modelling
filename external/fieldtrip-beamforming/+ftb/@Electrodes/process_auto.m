function obj = process_auto(obj)

% Try automatic alignment
% Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
obj.align_electrodes('fiducial');

% Visualization - check alignment
h = figure;
elements = {'electrodes-aligned', 'electrodes-labels', 'scalp', 'fiducials'};
obj.plot(elements);

% Interactive alignment
prompt = 'How''s it looking? Need manual alignment? (Y/n)';
response = input(prompt, 's');
if isequal(response, 'Y')
    close(h);
    % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
    obj.align_electrodes('interactive',...
        'Input',obj.elec_aligned);
end

% Visualization - check alignment
h = figure;
elements = {'electrodes-aligned', 'electrodes-labels', 'scalp', 'fiducials'};
obj.plot(elements);

% Convert units
if isfield(obj.config,'units')
    fprintf('%s: converting units to %s\n', mfilename, obj.config.units);
    elec = ftb.util.loadvar(obj.elec_aligned);
    elec = ft_convert_units(elec, obj.config.units);
    save(obj.elec_aligned, 'elec');
end

end