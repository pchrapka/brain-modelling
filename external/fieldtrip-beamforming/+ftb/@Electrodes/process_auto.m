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
    
    % load
    elec = ftb.util.loadvar(obj.elec_aligned);
    % convert
    elec = ft_convert_units(elec, obj.config.units);
    
    % save
    save(obj.elec_aligned, 'elec');
end

if isfield(obj.config,'ft_channelselection')
    fprintf('%s: selecting channels\n',...
        strrep(class(obj),'ftb.',''));
    
    elec = ftb.util.loadvar(obj.elec_aligned);
    channels = ft_channelselection(obj.config.ft_channelselection,elec.label);
    [~, channel_idx] = match_str(channels, elec.label);
    
    % select wanted channels
    elec.chanpos = elec.chanpos(channel_idx,:);
    elec.elecpos = elec.elecpos(channel_idx,:);
    elec.label = elec.label(channel_idx);
    
    % save
    save(obj.elec_aligned, 'elec');
end

end