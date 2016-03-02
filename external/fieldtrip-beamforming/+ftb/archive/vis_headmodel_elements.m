function vis_headmodel_elements(cfg)
%   cfg.elements
%       cell array of head model elements to be plotted: 
%           'electrodes', 'volume', 'leadfield'
%       TODO Add dipole
%   cfg.stage
%       struct of short names for each pipeline stage
%
%   See also ftb.get_stage

unit = 'mm';

for i=1:length(cfg.elements)
    switch cfg.elements{i}
        case 'scalp'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'headmodel');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            vol = ftb.util.loadvar(cfghm.files.mri_headmodel);
            
            % Convert to mm
            vol = ft_convert_units(vol, unit);
            
            % Plot the scalp
            if isfield(vol, 'bnd')
                switch vol.type
                    case 'bemcp'
                        ft_plot_mesh(vol.bnd(3),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'dipoli'
                        ft_plot_mesh(vol.bnd(1),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'openmeeg'
                        idx = vol.skin_surface;
                        ft_plot_mesh(vol.bnd(idx),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    otherwise
                        error(['ftb:' mfilename],...
                            'Which one is the scalp?');
                end
            elseif isfield(vol, 'r')
                ft_plot_vol(vol,...
                    'facecolor', 'none',...
                    'faceindex', false,...
                    'vertexindex', false);
            end
            
        case 'brain'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'headmodel');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            vol = ftb.util.loadvar(cfghm.files.mri_headmodel);
            
            % Convert to mm
            vol = ft_convert_units(vol, unit);
            
            % Plot the scalp
            if isfield(vol, 'bnd')
                switch vol.type
                    case 'bemcp'
                        ft_plot_mesh(vol.bnd(1),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'dipoli'
                        ft_plot_mesh(vol.bnd(3),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'openmeeg'
                        idx = vol.source;
                        ft_plot_mesh(vol.bnd(idx),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    otherwise
                        error(['ftb:' mfilename],...
                            'Which one is the brain?');
                end
            else
                error(['ftb:' mfilename],...
                    'Which one is the brain?');
            end
            
        case 'electrodes'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'electrodes');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            elec = ftb.util.loadvar(cfghm.files.elec_aligned);
            
            % Convert to mm
            elec = ft_convert_units(elec, unit);
            
            % Plot electrodes
            ft_plot_sens(elec,...
                'style', 'sk',...
                'coil', true);
            %'coil', false,...
            %'label', 'label');
            
        case 'leadfield'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'leadfield');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            leadfield = ftb.util.loadvar(cfghm.files.leadfield);
            
            % Convert to mm
            leadfield = ft_convert_units(leadfield, unit);
            
            % Plot inside points
            plot3(...
                leadfield.pos(leadfield.inside,1),...
                leadfield.pos(leadfield.inside,2),...
                leadfield.pos(leadfield.inside,3), 'k.');
            
        case 'dipole'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'dipolesim');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            
            signal_components = {'signal','interference'};
            
            for i=1:length(signal_components)
                component = signal_components{i};
                if ~isfield(cfghm, component)
                    % Skip if component not specified
                    continue;
                end
                
                switch component
                    case 'signal'
                        color = 'blue';
                    case 'interference'
                        color = 'red';
                    otherwise
                end
                
                params = cfghm.(component).ft_dipolesimulation;
                if isfield(params, 'dip')
                    dip = params.dip;
                    if ~isequal(dip.unit, unit)
                        switch dip.unit
                            case 'cm'
                                dip.pos = dip.pos*10;
                            otherwise
                                error(['ftb:' mfilename],...
                                    'implement unit %s', dip.unit);
                        end
                    end
                    ft_plot_dipole(dip.pos, dip.mom,...
                        ...'diameter',5,...
                        ...'length', 10,...
                        'color', color,...
                        'unit', unit);
                end
            end
            
        otherwise
            error(['fb:' mfilename],...
                'unknown element %s', cfg.elements{i});
    end
end

end

