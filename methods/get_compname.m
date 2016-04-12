function name = get_compname()
%GET_COMPNAME returns the computer name
%   NAME = GET_COMPNAME() returns the computer name

[ret, name] = system('hostname'); 

if ret ~= 0
    if ispc
        name = getenv('COMPUTERNAME');
    else
        name = getenv('HOSTNAME');
    end
end

end