function patches = get_aal_coarse(atlasfile,varargin)
%GET_AAL_COARSE returns anatomical labels partitioned into patches
%   GET_AAL_COARSE(atlasfile,...) returns a coarse partition of the AAL
%   atlas into 13 patches
%
%   Input
%   -----
%   atlasfile (string)
%       atlas filename
%
%   Parameters
%   ----------
%   verbosity (default = 0)
%       toggles verbosity level
%   
%   Output
%   ------
%   patches (struct array)
%       struct describing each patch
%   patches.name (string)
%       name of patch
%   patches.patterns (cell array of strings)
%       regexp patterns for finding anatomical labels in the atlas
%   patches.labels (cell array of string)
%       anatomical labels that make up the patch, each patch contains a
%       mutually exclusive set of labels
%   patches.atlasfile (string)
%       path of associated atlas file

% FIXME atlas_file should point to the AAL atlas in fieldtrip, how do I
% check for this?

p = inputParser;
addRequired(p,'atlasfile',@ischar);
addParameter(p,'verbosity',0);
parse(p,atlasfile,varargin{:});

atlas = ft_read_atlas(p.Results.atlasfile);

patches = [];
k = 1;

patches(k).name = 'midline fronto-polar';
patches(k).patterns = {...
    'Frontal_Mid_Orb.+',...
    'Frontal_Med_Orb.+',...
    'Frontal_Sup_Orb.+',...
    'Rectus.+',...
    'Olfactory.+',...
    };
k = k+1;

patches(k).name = 'frontal left';
patches(k).patterns = {...
    'Frontal_Mid_L',...
    'Frontal_Inf.+L',...
    };
k = k+1;

patches(k).name = 'frontal midline';
patches(k).patterns = {...
    'Frontal_Sup_L',...
    'Frontal_Sup_R',...
    'Frontal_Sup_Medial.+',...
    'Paracentral.+',...
    };
k = k+1;

patches(k).name = 'frontal right';
patches(k).patterns = {...
    'Frontal_Mid_R',...
    'Frontal_Inf.+R',...
    };
k = k+1;

patches(k).name = 'central left';
patches(k).patterns = {...
    'Precentral_L',...
    'Postcentral_L',...
    'Rolandic.+L',...
    };
k = k+1;

patches(k).name = 'central midline';
patches(k).patterns = {...
    'Supp_Motor_Area.+',...
    };
k = k+1;

patches(k).name = 'central right';
patches(k).patterns = {...
    'Precentral_R',...
    'Postcentral_R',...
    'Rolandic.+R',...
    };
k = k+1;

patches(k).name = 'temporal right';
patches(k).patterns = {...
    'Temporal.+R',...
    'Heschl_R',...
    };
k = k+1;

patches(k).name = 'temporal left';
patches(k).patterns = {...
    'Temporal.+L',...
    'Heschl_L',...
    };
k = k+1;

patches(k).name = 'parietal left';
patches(k).patterns = {...
    'Parietal.*L',...
    'Angular_L',...
    'SupraMarginal_L',...
    };
k = k+1;

patches(k).name = 'parietal midline';
patches(k).patterns = {...
    'Precu.*',...
    };
k = k+1;

patches(k).name = 'parietal right';
patches(k).patterns = {...
    'Parietal.*R',...
    'Angular_R',...
    'SupraMarginal_R',...
    };
k = k+1;

% TODO maybe separate occipito lateral surface into L and R
patches(k).name = 'midline occipito-polar';
patches(k).patterns = {...
    'Occipital.*',...
    'Cune.*',...
    'Lingual.*',...
    'Fusiform.*',...
    'Calcarine.*',...
    };
k = k+1;

for i=1:length(patches)
    % TODO it's easier to write regexp above, but if it's not changing much
    % it might be easier to hardcode
    
    % find all tissuelabel matches in the atlas
    matches_all = {};
    for j=1:length(patches(i).patterns)
        matches = ftb.util.regexpmatchlist(atlas.tissuelabel, patches(i).patterns{j});
        matches_all = [matches_all matches];
    end
    patches(i).labels = matches_all;
    
    if p.Results.verbosity > 0
        % print tissue labels for each patch
        fprintf('patch: %s\n',patches(i).name);
        for j=1:length(matches_all)
            fprintf('\t%s\n',matches_all{j});
        end
    end
end
% save atlasfile
[patches.atlasfile] = deal(p.Results.atlasfile);

end