cmd = 'find . -type f -name ''*pdc-dynamic-diag-f2048*.mat''';
[~,result] = system(cmd);

result2 = regexp(result,'\n','split');

for i=1:length(result2)
    if isempty(result2{i})
        continue;
    end
    fprintf('loading file %d\n',i);
    data = loadfile(result2{i});
    if size(data.pdc,4) >= 42
        fprintf('\tfixing\n');
        data.pdc(:,:,:,42:end) = [];
        save_parfor(result2{i}, data);
    else
        fprintf('\tok\n');
    end
end