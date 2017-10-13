function cfg = BFPatchAAL_andrew(meta_data)
% BFPatchAAL

cfg = [];
cfg.PatchModel = {'aal'};

cfg.cov_avg = 'yes';
cfg.compute_lcmv_patch_filters = {'mode','single','fixedori',true}; % for saving mem
% cfg.compute_lcmv_patch_filters = {'mode','all','fixedori',true}; % for plotting
cfg.ft_sourceanalysis.rawtrial = 'yes';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';
cfg.ft_sourceanalysis.lcmv.lambda = '1%';

meta_data.load_bad_channels();
% add minus signs in front of each channel
badchannel_list = cellfun(@(x) ['-' x], meta_data.elecbad_channels, 'UniformOutput',false);
% add bad channels
cfg.ft_sourceanalysis.channel = ['EEG', badchannel_list(:)'];

cfg.name = sprintf('%s-%s',...
    cfg.PatchModel{1},...
    cfg.ft_sourceanalysis.method);

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end