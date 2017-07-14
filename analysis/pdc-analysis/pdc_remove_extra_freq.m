cmd = 'find . -type f -name ''*pdc-dynamic-diag-f2048*.mat''';
[~,result] = system(cmd);

result2 = regexp(result,'\n','split');

for i=1:length(result2)
    fprintf('loading file %d\n',i);
    data = loadfile(result2{i});
    data.pdc(:,:,:,42:end) = [];
    save_parfor(result2{i}, data);
end