function params = Eandrew_cm(meta_data)
% Eandrew_cm

params = [];
params.name = [strrep('andrew_cm','_','-') '-' meta_data.data_name(1:3)];
% Processing options
params.elec_orig = meta_data.elec_file;
params.units = 'cm';
params.fiducials = {...
    'NAS','NZ',...
    'LPA','LPA',...
    'RPA','RPA',...
    };
params.mode = 'fiducial-exact';
params.ft_electroderealign.casesensitive = 'no';

% remove unnecessary channels from later processing
params.ft_channelselection = {'all','-NZ','-LPA','-RPA','-CMS'};

meta_data.load_bad_channels();
% add minus signs in front of each channel
badchannel_list = cellfun(@(x) ['-' x], meta_data.elecbad_channels, 'UniformOutput',false);
params.ft_channelselection = [params.ft_channelselection, badchannel_list(:)'];

% save config
config_file = [strrep(mfilename,'_','-') '-' meta_data.data_name(1:3) '.mat'];

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, config_file),'params');

end