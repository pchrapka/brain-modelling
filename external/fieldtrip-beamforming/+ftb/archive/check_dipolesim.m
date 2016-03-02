function check_dipolesim(cfg)
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   cfg.stage.headmodel
%       head model name
%   cfg.stage.electrodes
%       electrode configuration name
%   cfg.stage.dipolesim
%       dipole simulation name

debug = true;
if debug
    cfgtmp = ftb.get_stage(cfg, 'dipolesim');
    cfghm = ftb.load_config(cfgtmp.stage.full);
    
    datafile = cfghm.files.ft_dipolesignal.signal;
    if exist(datafile,'file')
        data = ftb.util.loadvar(datafile);
        figure;
        % Show the first trial
        plot(data{1});
        xlim([0 length(data{1})]);
    end
end

if debug
    cfgtmp = ftb.get_stage(cfg, 'dipolesim');
    cfghm = ftb.load_config(cfgtmp.stage.full);
    data = ftb.util.loadvar(cfghm.files.adjust_snr.all);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.signal);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.interference);

    figure;
    ft_databrowser([], data);
end

if debug
    cfgtmp = ftb.get_stage(cfg, 'dipolesim');
    cfghm = ftb.load_config(cfgtmp.stage.full);
    data = ftb.util.loadvar(cfghm.files.ft_dipolesimulation.signal);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.signal);
%     data = ftb.util.loadvar(cfghm.files.adjust_snr.interference);

    figure;
    ft_databrowser([], data);
end


if debug
    cfgin = [];
    cfgin.stage = cfg.stage;
    cfgin.elements = {'brain', 'dipole'};
    
    figure;
    ftb.vis_headmodel_elements(cfgin);
end

end