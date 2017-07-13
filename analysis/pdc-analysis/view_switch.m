function view_obj = view_switch(view_obj,name)

switch name
    case 'beta'
        view_obj.set_freqrange([15 25],'type','f');
    case '5'
        view_obj.set_freqrange([0 5],'type','f')
    case '10'
        view_obj.set_freqrange([0 10],'type','f')
    case '100'
        view_obj.set_freqrange([0.01 100],'type','f')
    otherwise
        error('unknown view settings');
end
end
