function [name,order] = get_atlas_region_aal_coarse_19(label)

order = [];

pattern = '(\w+)\s(Left|Right|Mid)\>';
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
    case 'Temporal'
        order = 6;
    case 'Occipital'
        order = 7;
    case 'Limbic'
        order = 8;
    case 'Cerebellum'
        order = 9;
        
    otherwise
        fprintf('%s not assigned\n',name);
end

end