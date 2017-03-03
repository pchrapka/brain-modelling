function view_obj = view_switch(view_obj,name)

switch name
    case 'beta'
        view_obj.w = [15 25]/view_obj.fs;
    case '10'
        view_obj.w = [0 10]/view_obj.fs;
    case '100'
        view_obj.w = [0 100]/view_obj.fs;
    otherwise
        error('unknown view settings');
end
end
