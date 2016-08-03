function Eandrew_s04_warpgr_cm()
% Eandrew_s04_warpgr_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

cfg = [];
% Processing options
cfg.elec_orig = fullfile(srcdir,'..','..','..','..','data-andrew-beta','exp04.sfp');
cfg.units = 'cm';
cfg.fiducials = {...
    'NAS','NZ',...
    'LPA','LPA',...
    'RPA','RPA',...
    };
cfg.mode = 'fiducial-template';
cfg.ft_electroderealign.warp = 'globalrescale';
cfg.ft_electroderealign.casesensitive = 'no';

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end