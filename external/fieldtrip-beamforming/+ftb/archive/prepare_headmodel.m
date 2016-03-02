function cfg = prepare_headmodel(stage)
%
%   stage.headmodel

cfg = [];
cfg.stage.headmodel = stage.headmodel;

switch stage.headmodel
    case 'HMbemcp'
        % Processing options
        cfg.ft_volumesegment.output = {'brain','skull','scalp'};
        cfg.ft_prepare_mesh.method = 'projectmesh';
        cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
        cfg.ft_prepare_mesh.numvertices = [2000, 1500, 1000];
        cfg.ft_prepare_headmodel.method = 'bemcp';
        % MRI data
        cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');
        
    case 'HMopenmeeg'
        % Processing options
        cfg.ft_volumesegment.output = {'brain','skull','scalp'};
        cfg.ft_prepare_mesh.method = 'projectmesh';
        cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
        cfg.ft_prepare_mesh.numvertices = [2000, 2000, 1000];
        % NOTE [3000, 2000, 1000] gives me an error: Mesh is self intersecting
        cfg.ft_prepare_headmodel.method = 'openmeeg';
        % MRI data
        cfg.mri_data = fullfile('anatomy','Subject01','Subject01.mri');
    otherwise
        error(['ftb:' mfilename],...
            'unknown headmodel %s', stage.headmodel);
end

end