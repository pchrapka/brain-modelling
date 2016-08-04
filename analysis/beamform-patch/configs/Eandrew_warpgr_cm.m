function Eandrew_warpgr_cm(elec_file, data_name)
% Eandrew_warpgr_cm

p = inputParser;
addRequired(p,'elec_file',@ischar);
addRequired(p,'data_name',@ischar);
parse(p,elec_file,data_name);

cfg = [];
cfg.name = ['E' strrep(mfilename,'_','-') data_name(1:3)];
% Processing options
cfg.elec_orig = elec_file;
cfg.units = 'cm';
cfg.fiducials = {...
    'NAS','NZ',...
    'LPA','LPA',...
    'RPA','RPA',...
    };
cfg.mode = 'fiducial-template';
cfg.ft_electroderealign.warp = 'globalrescale';
cfg.ft_electroderealign.casesensitive = 'no';

% save config
config_file = [strrep(mfilename,'_','-') '-' data_name(1:3) '.mat'];

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, config_file),'cfg');

end