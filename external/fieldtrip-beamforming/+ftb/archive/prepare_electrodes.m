function cfg = prepare_electrodes(stage)
%
%   stage.headmodel
%   stage.electrodes

cfg = [];
cfg.stage.headmodel = stage.headmodel;
cfg.stage.electrodes = stage.electrodes;

% Set up electrode config
switch stage.electrodes
    case 'E256'     
        cfg.elec_orig = 'GSN-HydroCel-256.sfp';
    otherwise
        error(['ftb:' mfilename],...
            'unknown headmodel %s', stage.electrodes);
end

end