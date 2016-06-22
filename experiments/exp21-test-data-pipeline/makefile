all: output.mat

input.mat:
	matlab -nodisplay -nosplash -nodesktop -r "try, test_create_data([],'input.mat',[]), catch, exit(1), end, exit(0)"

output.mat: input.mat params_test.m
	matlab -nodisplay -nosplash -r "try, test_bash_func('input.mat','output.mat','params_test'), catch, exit(1), end, exit(0)"
