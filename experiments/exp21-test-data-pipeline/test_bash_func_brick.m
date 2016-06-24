function [file_in,file_out,param_func] = test_bash_func_brick(file_in,file_out,param_func)

% get params
params = feval(param_func);

% load input file
din = load(file_in);

signal = sin(2*pi*params.f*din.t);

save(file_out,'signal');

end