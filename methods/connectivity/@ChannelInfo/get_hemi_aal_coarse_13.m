function [name,order] = get_hemi_aal_coarse_13(label)

pattern = '\s(left|right)\>';
result = regexp(label,pattern,'tokens');

if isempty(result)
    value = 'N';
else
    value = result{1}{1};
end

switch value
    case 'N'
        name = 'None';
        order = 2;
    case 'left'
        name = 'Left';
        order = 3;
    case 'right'
        name = 'Right';
        order = 1;
    otherwise
        error('something went wrong here: %s',value);
end

end