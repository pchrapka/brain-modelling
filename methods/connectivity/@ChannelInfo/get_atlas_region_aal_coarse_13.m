function [name,order] = get_atlas_region_aal_coarse_13(label)

name = '';
order = [];
switch label
    case 'midline fronto-polar'
        name = 'Fronto-Polar';
        order = 1;
    case {'frontal left','frontal right','frontal midline'}
        name = 'Frontal';
        order = 2;
    case {'central left','central right','central midline'}
        name = 'Central';
        order = 3;
    case {'temporal left','temporal right'}
        name = 'Temporal';
        order = 4;
    case {'parietal left','parietal right','parietal midline'}
        name = 'Parietal';
        order = 5;
    case 'midline occipito-polar'
        name = 'Occipital';
        order = 6;
    otherwise
        fprintf('%s not assigned\n',label);
end