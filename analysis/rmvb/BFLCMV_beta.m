function cfg = BFLCMV_beta(meta_data,varargin)

p = inputParser();
parse(p,varargin{:});

cfg = [];

% cfg.ft_sourceanalysis.rawtrial = 'yes';
cfg.ft_sourceanalysis.rawtrial = 'no';
cfg.ft_sourceanalysis.keeptrials = 'no';
cfg.ft_sourceanalysis.method = 'lcmv';
cfg.ft_sourceanalysis.lcmv.keepmom = 'yes';
cfg.ft_sourceanalysis.lcmv.lambda = '1%';

meta_data.load_bad_channels();
% add minus signs in front of each channel
badchannel_list = cellfun(@(x) ['-' x], meta_data.elecbad_channels, 'UniformOutput',false);
% add bad channels
cfg.ft_sourceanalysis.channel = ['EEG', badchannel_list(:)'];

cfg.name = sprintf('%s-%s',...
    cfg.ft_sourceanalysis.method,...
    meta_data.data_name(1:3));

% [srcdir,~,~] = fileparts(mfilename('fullpath'));
% save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end