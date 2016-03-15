function [pathstr, name, ext, versn] = fileparts(file_name)
    versn = 0;
    if verLessThan('matlab', '7.14')
        [pathstr, name, ext, versn] = fileparts(file_name);
    else
        [pathstr, name, ext] = fileparts(file_name);
    end
end