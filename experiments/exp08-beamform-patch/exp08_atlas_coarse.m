%% exp08_atlas_coarse

%% load the atlas
matlab_dir = userpath;
pathstr = fullfile(matlab_dir(1:end-1),'fieldtrip-20160128','template','atlas','aal');
atlas_file = fullfile(pathstr,'ROI_MNI_V4.nii');

atlas = ft_read_atlas(atlas_file);

%% plot regions
regions = [];
k = 1;

regions(k).name = 'midline fronto-polar';
regions(k).patterns = {...
    'Frontal.+Orb.+',...
    'Rectus.+',...
    'Olfactory.+',...
    };
k = k+1;
% FIXME weird


regions(k).name = 'frontal left';
regions(k).patterns = {...
    'Frontal_Mid_L',...
    'Frontal_Inf.+L',...
    };
k = k+1;

regions(k).name = 'frontal midline';
regions(k).patterns = {...
    'Frontal_Sup_L',...
    'Frontal_Sup_R',...
    'Frontal_Sup_Medial.+',...
    'Paracentral.+',...
    };
k = k+1;

regions(k).name = 'frontal right';
regions(k).patterns = {...
    'Frontal_Mid_R',...
    'Frontal_Inf.+R',...
    };
k = k+1;

regions(k).name = 'central left';
regions(k).patterns = {...
    'Precentral_L',...
    'Postcentral_L',...
    'Rolandic.+L',...
    };
k = k+1;

regions(k).name = 'central midline';
regions(k).patterns = {...
    'Supp_Motor_Area.+',...
    };
k = k+1;

regions(k).name = 'central right';
regions(k).patterns = {...
    'Precentral_R',...
    'Postcentral_R',...
    'Rolandic.+R',...
    };
k = k+1;

regions(k).name = 'temporal right';
regions(k).patterns = {...
    'Temporal.+R',...
    'Heschl_R',...
    };
k = k+1;

regions(k).name = 'temporal left';
regions(k).patterns = {...
    'Temporal.+L',...
    'Heschl_L',...
    };
k = k+1;

regions(k).name = 'parietal left';
regions(k).patterns = {...
    'Parietal.*L',...
    'Angular_L',...
    'SupraMarginal_L',...
    };
k = k+1;

regions(k).name = 'parietal midline';
regions(k).patterns = {...
    'Precu.*',...
    };
k = k+1;

regions(k).name = 'parietal right';
regions(k).patterns = {...
    'Parietal.*R',...
    'Angular_R',...
    'SupraMarginal_R',...
    };
k = k+1;

% TODO maybe separate occipito lateral surface into L and R
regions(k).name = 'midline occipito-polar';
regions(k).patterns = {...
    'Occipital.*',...
    'Cune.*',...
    'Lingual.*',...
    'Fusiform.*',...
    'Calcarine.*',...
    };
k = k+1;

regions_all = {};
for i=1:length(regions)
    matches_all = {};
    for j=1:length(regions(i).patterns)
        matches = regexpmatchlist(atlas.tissuelabel, regions(i).patterns{j});
        matches_all = [matches_all matches];
    end
    regions_all = [regions_all matches_all];
    fprintf('region: %s\n',regions(i).name);
    for j=1:length(matches_all)
        fprintf('\t%s\n',matches_all{j});
    end
    plot_atlas(atlas,'nslices',30,'roi', matches_all);
    
    title(regions(i).name);
end

plot_atlas(atlas,'nslices',30,'roi', regions_all);
title('regions accounted for');

%% left over areas
% TODO left over
% most of limibc lobe
% insula
% sub cortcal gray nuclei
% cerebellum

pattern = 'Insula.*';
% pattern = 'Cingulum.*';
% pattern = 'Hippo.*';
% pattern = 'ParaHippo.*';
% pattern = 'Amygdala.*';
% pattern = 'Caudate.*';
% pattern = 'Putamen.*';
% pattern = 'Thalamus.*';
% pattern = 'Pallidum.*';
% pattern = 'Cerebelum.*';
% pattern = 'Vermis.*';
matches = regexpmatchlist(atlas.tissuelabel, pattern);
plot_atlas(atlas,'roi',matches);

name = strrep(pattern,'.*','');
title(name);