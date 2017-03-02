function [name,order] = get_hemi_aal(label,mode)

p = inputParser();
addRequired(p,'label',@ischar);
addRequired(p,'mode',@(x) any(validatestring(x,{'single','full'})));
parse(p,label,mode);

switch mode
    case 'single'
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
        
    case 'full'
        pattern = '\s(left|right)\>';
        result = regexpi(label,pattern,'tokens');
        
        if isempty(result)
            value = 'none';
        else
            value = result{1}{1};
        end
        
        switch lower(value)
            case 'none'
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
    otherwise
        error('what should i do for %s',mode);
end

end