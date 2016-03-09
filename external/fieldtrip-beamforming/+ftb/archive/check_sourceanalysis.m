function check_sourceanalysis(cfg)
%   
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%   cfg.stage.electrodes
%       electrode configuration name
%   cfg.stage.leadfield
%       lead field name
%   cfg.stage.dipolesim
%       dipole simulation name
%   cfg.stage.beamformer
%       source analysis name
%
%   cfg.contrast
%       (optional) name of dipolesim to contrast

for i=1:length(cfg.checks)
    switch cfg.checks{i}
        case 'anatomical'
            
            % Load source analysis
            cfgtmp = ftb.get_stage(cfg);
            cfgsource = ftb.load_config(cfgtmp.stage.full);
            source = ftb.util.loadvar(cfgsource.files.ft_sourceanalysis.all);
            
            % Load the head model
            cfgtmp = ftb.get_stage(cfg, 'headmodel');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            volume = ftb.util.loadvar(cfghm.files.mri_headmodel);
            
            if isfield(cfg, 'contrast')
                % Load noise source
                cfgcopy = cfg;
                cfgcopy.stage.dipolesim = cfg.contrast;
                cfgtmp = ftb.get_stage(cfgcopy);
                cfgnoise = ftb.load_config(cfgtmp.stage.full);
                source_noise = ftb.util.loadvar(cfgnoise.files.ft_sourceanalysis.all);
            end
            
            cfgin = [];
            mri = ftb.util.loadvar(cfghm.files.mri_mat);
            resliced = ft_volumereslice(cfgin, mri);
            
            % Take neural activity index
            % NOTE doesn't seem to help
            sourcenai = source;
            if exist('source_noise', 'var')
                sourcenai.avg.pow = source.avg.pow ./ source_noise.avg.pow - 1;
            end
            %sourcenai.avg.pow = source.avg.pow ./ source.avg.noise;
            
            cfgin = [];
            cfgin.parameter = 'pow';
            interp = ft_sourceinterpolate(cfgin, sourcenai, resliced);
            
            cfgin = [];
            cfgin.method = 'slice';
%             cfgin.method = 'ortho';
            cfgin.funparameter = 'pow';
            ft_sourceplot(cfgin, interp);
            
            
        case 'headmodel'
            figure;
            
            cfgin = [];
            cfgin.stage = cfg.stage;
            cfgin.elements = {'brain', 'dipole', 'leadfield', 'electrodes'};
            ftb.vis_headmodel_elements(cfgin);
            
            
        case 'scatter'
            figure;
            cfgin = cfg;
            ftb.vis_sourceanalysis(cfgin);
            
            cfgbf = ftb.get_stage(cfg, 'beamformer');
            title(strrep(cfgbf.stage.full,'_' ,' '));
            
        otherwise
            error(['fb:' mfilename],...
                'unknown check %s', cfg.checks{i});
    end
    
end

end