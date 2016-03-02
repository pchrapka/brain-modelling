function cfg = prepare_leadfield(stage)
%
%   stage.headmodel
%   stage.electrodes
%   stage.leadfield

cfg = [];
cfg.stage.headmodel = stage.headmodel;
cfg.stage.electrodes = stage.electrodes;
cfg.stage.leadfield = stage.leadfield;

% Set up leadfield config
switch stage.leadfield
    case 'Lsurf10mm';
%         cfg.ft_prepare_sourcemodel.grid.resolution = 10;
%         cfg.ft_prepare_sourcemodel.grid.unit = 'mm';
        cfg.ft_prepare_sourcemodel = [];
        cfg.ft_prepare_sourcemodel.grid.unit = 'mm';
        
    case 'L1cm'
        cfg.ft_prepare_leadfield.grid.resolution = 1;
        cfg.ft_prepare_leadfield.grid.unit = 'cm';
        
    case 'L1mm'
        resolution = 1;
        cfg.ft_prepare_leadfield.grid.xgrid = -60:resolution:110;
        cfg.ft_prepare_leadfield.grid.ygrid = -70:resolution:60;
        cfg.ft_prepare_leadfield.grid.zgrid = -10:resolution:120;
%         cfg.ft_prepare_leadfield.grid.resolution = 10;
        cfg.ft_prepare_leadfield.grid.unit = 'mm';
        
    case 'L5mm'
        resolution = 5;
        cfg.ft_prepare_leadfield.grid.xgrid = -60:resolution:110;
        cfg.ft_prepare_leadfield.grid.ygrid = -70:resolution:60;
        cfg.ft_prepare_leadfield.grid.zgrid = -10:resolution:120;
%         cfg.ft_prepare_leadfield.grid.resolution = 5;
        cfg.ft_prepare_leadfield.grid.unit = 'mm';
        
    case 'L10mm'
        resolution = 10;
        cfg.ft_prepare_leadfield.grid.xgrid = -60:resolution:110;
        cfg.ft_prepare_leadfield.grid.ygrid = -70:resolution:60;
        cfg.ft_prepare_leadfield.grid.zgrid = -10:resolution:120;
%         cfg.ft_prepare_leadfield.grid.resolution = 10;
        cfg.ft_prepare_leadfield.grid.unit = 'mm';
        
    case 'Llinx10mm'
        % The lead field is on a linear grid in the x direction with 10mm
        % spacing
        cfg.ft_prepare_leadfield.grid.xgrid = -100:1:100;
        cfg.ft_prepare_leadfield.grid.ygrid = 0;
        cfg.ft_prepare_leadfield.grid.zgrid = 10;
        % cfg.ft_prepare_leadfield.grid.resolution = 10;
        cfg.ft_prepare_leadfield.grid.unit = 'mm';
        
    case 'Lliny10mm'
        % The lead field is on a linear grid in the y direction with 10mm
        % spacing

        cfg.ft_prepare_leadfield.grid.xgrid = -50;
        cfg.ft_prepare_leadfield.grid.ygrid = -100:10:100;
        cfg.ft_prepare_leadfield.grid.zgrid = 50;
        % cfg.ft_prepare_leadfield.grid.resolution = 10;
        cfg.ft_prepare_leadfield.grid.unit = 'mm';
        
    case 'Lliny1mm'
        % The lead field is on a linear grid in the y direction with 10mm
        % spacing
        
        cfg.ft_prepare_leadfield.grid.xgrid = -50;
        cfg.ft_prepare_leadfield.grid.ygrid = -100:1:100;
        cfg.ft_prepare_leadfield.grid.zgrid = 50;
        % cfg.ft_prepare_leadfield.grid.resolution = 10;
        cfg.ft_prepare_leadfield.grid.unit = 'mm';
        
    otherwise
        error(['ftb:' mfilename],...
            'unknown leadfield cfg %s', stage.leadfield);
end

end
