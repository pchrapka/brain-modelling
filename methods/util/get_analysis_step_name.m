function step_name = get_analysis_step_name(param_file, prefix)

if ischar(param_file)
    pattern = [prefix '(.*).mat'];
    results = regexp(param_file,pattern,'tokens');
    step_name = results{1}{1};
else
    step_name = param_file.name;
end

end