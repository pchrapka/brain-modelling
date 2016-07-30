function step_name = get_analysis_step_name(param_file, prefix)

pattern = [prefix '(.*).mat'];
results = regexp(param_file,pattern,'tokens');
step_name = results{1}{1};

end