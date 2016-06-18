function [file_in,file_out,param_func] = test_create_data_brick(file_in,file_out,param_func)

t = linspace(0,2*pi,100);

save(file_out,'t');

end