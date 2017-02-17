function hemis = get_hemi(obj)

nlabels = length(obj.label);
hemis = struct('name','','order',num2cell(zeros(nlabels,1)));
for i=1:nlabels
    
    pattern = '\s(L|R)\>';
    result = regexp(obj.label{i},pattern,'tokens');
    
    if isempty(result)
        value = 'N';
    else
        value = result{1}{1};
    end
    
    switch value
        case 'N'
            hemis(i).name = 'None';
            hemis(i).order = 2;
        case 'L'
            hemis(i).name = 'Left';
            hemis(i).order = 3;
        case 'R'
            hemis(i).name = 'Right';
            hemis(i).order = 1;
        otherwise
            error('something went wrong here: %s',value);
    end
    
    %disp(obj.label{i});
    %disp(hemis(i));
end

end