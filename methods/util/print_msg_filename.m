function print_msg_filename(datafile,msg)

[filepath,filename,fileext] = fileparts(datafile);
fprintf('%s %s%s\n\tin: %s\n',msg,filename,fileext,filepath);

end