function cfg = BFRMV_beta(meta_data,varargin)

p = inputParser();
addParameter(p,'epsilon',0,@isnumeric);
parse(p,varargin{:});

cfg = [];

cfg.cov_avg = 'yes';
cfg.compute_rmv_filters = {};
cfg.BeamformerRMV.aniso = false;
cfg.BeamformerRMV.epsilon = p.Results.epsilon;
cfg.ft_sourceanalysis.rawtrial = 'yes';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';

meta_data.load_bad_channels();
% add minus signs in front of each channel
badchannel_list = cellfun(@(x) ['-' x], meta_data.elecbad_channels, 'UniformOutput',false);
% add bad channels
cfg.ft_sourceanalysis.channel = ['EEG', badchannel_list(:)'];

cfg.name = sprintf('%s-%s-%s',...
    strrep(sprintf('%0.6g',cfg.BeamformerRVB.epsilon),'.','-'),...
    cfg.ft_sourceanalysis.method,...
    meta_data.data_name(1:3));

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end