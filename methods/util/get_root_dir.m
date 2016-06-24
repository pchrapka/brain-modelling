function rootdir = get_root_dir(comp_name)
% get the root dir based on the computer name
switch comp_name
    case {'blade16.ece.mcmaster.ca', sprintf('blade16.ece.mcmaster.ca\n')}
        rootdir = '/home/chrapkpk/Documents';
    case {sprintf('Valentina\n'), 'Valentina ', 'Valentina'}
        rootdir = '/home/phil';
    otherwise
        error('what is the root dir for %s',comp_name);
end

end