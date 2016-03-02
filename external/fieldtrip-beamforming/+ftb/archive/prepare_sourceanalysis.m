function cfg = prepare_sourceanalysis(stage)
%
%   stage.headmodel
%   stage.electrodes
%   stage.leadfield
%   stage.dipolesim

cfg = [];
cfg.stage.headmodel = stage.headmodel;
cfg.stage.electrodes = stage.electrodes;
cfg.stage.leadfield = stage.leadfield;
cfg.stage.dipolesim = stage.dipolesim;

% Set up beamformer config
switch stage.beamformer
    
    case 'BF1'
        cfg.stage.beamformer = stage.beamformer;
        cfg.ft_sourceanalysis.method = 'lcmv';
        cfg.ft_sourceanalysis.lcmv.keepmom = 'no';
%         cfg.ft_sourceanalysis.lcmv.projectnoise = 'yes';
        
    otherwise
        error(['ftb:' mfilename],...
            'unknown sourceanalysis %s', stage.beamformer);
end

end