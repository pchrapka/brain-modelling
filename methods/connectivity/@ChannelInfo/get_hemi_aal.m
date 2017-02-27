function [name,order] = get_hemi_aal(label)

pattern = '\s(L|R)\>';
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
    case 'L'
        name = 'Left';
        order = 3;
    case 'R'
        name = 'Right';
        order = 1;
    otherwise
        error('something went wrong here: %s',value);
end

end