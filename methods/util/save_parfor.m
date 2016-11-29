function save_parfor(filename, data)

[pathstr,~,~] = fileparts(filename);
if ~exist(pathstr,'dir')
    mkdir(pathstr);
end

save(filename, 'data');
end