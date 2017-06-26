function params = Eandrew_cm(elec_file, data_name)
% Eandrew_cm

p = inputParser;
addRequired(p,'elec_file',@ischar);
addRequired(p,'data_name',@ischar);
parse(p,elec_file,data_name);

params = [];
params.name = [strrep('andrew_cm','_','-') '-' data_name(1:3)];
% Processing options
params.elec_orig = elec_file;
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
switch data_name(1:3)
    case 's03'
        % all good
    case 's05'
        params.ft_channelselection = [params.ft_channelselection {'-A21'}];
    case 's06'
        params.ft_channelselection = [params.ft_channelselection {'-D32','-C10'}];
    otherwise
        error('update bad EEG channels for ft_channelselection in %s',mfilename);
end

% save config
config_file = [strrep(mfilename,'_','-') '-' data_name(1:3) '.mat'];

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, config_file),'params');

end