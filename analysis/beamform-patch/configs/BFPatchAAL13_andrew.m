function cfg = BFPatchAAL13_andrew(data_name)
% BFPatchAAL

cfg = [];
cfg.patch_model_name = 'aal-coarse-13';
% cfg.get_basis = {};
cfg.cov_avg = 'yes';
cfg.compute_lcmv_patch_filters = {'mode','single','fixedori',true}; % for saving mem
% cfg.compute_lcmv_patch_filters = {'mode','all','fixedori',true}; % for plotting
cfg.ft_sourceanalysis.rawtrial = 'yes';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';
cfg.ft_sourceanalysis.lcmv.lambda = '1%';
switch data_name(1:3)
    case 's06'
        cfg.ft_sourceanalysis.channel = {'EEG','-D32','-C10'};
    otherwise
        warning('update bad EEG channels for ft_sourceanalysis in %s',mfilename);
end

cfg.name = sprintf('%s-%s',...
    cfg.patch_model_name,...
    cfg.ft_sourceanalysis.method);

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end