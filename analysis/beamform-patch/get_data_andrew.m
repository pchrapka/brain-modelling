function [data_file,data_name,elec_file] = get_data_andrew(subject_num,deviant_percent)

p = inputParser();
addRequired(p,'subject_num',@(x) x >= 1 && x <= 10);
addRequired(p,'deviant_percent',@(y) any(arrayfun(@(x) isequal(x,y), [10 20])) );
parse(p,subject_num,deviant_percent);

% get the data folder
comp_name = get_compname();
switch comp_name
    case {'blade16.ece.mcmaster.ca', sprintf('blade16.ece.mcmaster.ca\n')}
        rootdir = get_root_dir(comp_name);
    otherwise
        rootdir = '/media/phil/p.eanut';
end

% set up outputs
data_dir = fullfile(rootdir,'projects','data-andrew-beta');
data_file = fullfile(data_dir,sprintf('exp%02d_%d.bdf',subject_num,deviant_percent));
elec_file = fullfile(data_dir,sprintf('exp%02d.sfp',subject_num));

data_name = sprintf('s%02d-%d',subject_num,deviant_percent);

end