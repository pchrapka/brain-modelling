function check_leadfield(cfg)
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

debug = true;
if debug
    cfgtmp = ftb.get_stage(cfg);
    cfglf = ftb.load_config(cfgtmp.stage.full);
    leadfield = ftb.util.loadvar(cfglf.files.leadfield);
    
    lf_inside = leadfield.leadfield(leadfield.inside);
    for i=1:length(lf_inside)
        result = sum(sum(isnan(lf_inside{i})));
        if result > 0
            fprintf('found nan %d\n', leadfield.inside(i));
        end
    end
end

if debug
    cfgin = [];
    cfgin.stage = cfg.stage;
    cfgin.elements = {'electrodes', 'scalp', 'leadfield'};
    ftb.vis_headmodel_elements(cfgin);
end

end