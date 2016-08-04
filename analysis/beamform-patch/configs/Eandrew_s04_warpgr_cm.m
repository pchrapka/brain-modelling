function Eandrew_s04_warpgr_cm()
% Eandrew_s04_warpgr_cm

subject_num = 4;
deviant_percent = 10;
[~,~,elec_file] = get_data_andrew(subject_num,deviant_percent);

% Processing options
cfg = [];
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

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end