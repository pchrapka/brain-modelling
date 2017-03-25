function [name,order] = get_atlas_region_aal_coarse_19_plus2(label)

order = [];

pattern = '([\w\s]+)\s(Left|Right|Mid)\>';
result = regexp(label,pattern,'tokens');

name = result{1}{1};

switch name
    
    case 'Prefrontal'
        order = 1;
    case 'Motor'
        order = 2;
    case 'Basal Ganglia'
        order = 3;
    case 'Insula'
        order = 4;
    case 'Parietal'
        order = 5;
    case 'Auditory'
        order = 6;
    case 'Temporal'
        order = 7;
    case 'Occipital'
        order = 8;
    case 'Limbic'
        order = 9;
    case 'Cerebellum'
        order = 10;
        
    otherwise
        fprintf('%s not assigned\n',name);
end

end