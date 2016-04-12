function [datadir,subject_file,subject_name] = get_coma_data(subject_num)

% get the computer name
comp_name = get_compname();

% get the root dir based on the computer name
switch comp_name
    case sprintf('blade16.ece.mcmaster.ca\n')
        rootdir = '/home/chrapkpk/Documents';
    case 'Valentina'
        rootdir = '/home/phil';
    otherwise
        error('what is the root dir for %s',comp_name);
end

% set up the data dir
datadir = fullfile(rootdir,'projects','data-coma-richard','BC-HC-YOUTH','Cleaned');

% get the subject file for the specific subject number
switch subject_num
    case 20
        subject_file = 'BC.HC.YOUTH.P020-10834';
    case 21
        subject_file = 'BC.HC.YOUTH.P021-10852';
    case 22
        subject_file = 'BC.HC.YOUTH.P022-9913';
    case 23
        subject_file = 'BC.HC.YOUTH.P023-10279';
    otherwise
        error('unknown subject %d',subject_num);
end

subject_name = strrep(subject_file,'BC.HC.YOUTH.','');

end