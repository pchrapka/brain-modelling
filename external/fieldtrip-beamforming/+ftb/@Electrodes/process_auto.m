function obj = process_auto(obj,varargin)

p = inputParser();
options_fiducial = {'fiducial-template','fiducial-exact'};
addParameter(p,'fiducial','fiducial-template',@(x) any(validatestring(x,options_fiducial)));
p.parse(varargin{:});

% Try automatic fiducial alignment
% Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
obj.align_electrodes(p.Results.fiducial);

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
    fprintf('%s: converting units to %s\n',...
        strrep(class(obj),'ftb.',''), obj.config.units);
    elec = ftb.util.loadvar(obj.elec_aligned);
    elec = ft_convert_units(elec, obj.config.units);
    save(obj.elec_aligned, 'elec');
end

end