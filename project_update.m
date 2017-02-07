function project_update()
%PROJECT_UPDATE updates path for project
%   PROJECT_UPDATE updates path for project
%
%   Meant for MATLAB versions older than 2015a. Sometimes if the code is
%   updated externally (i.e. via git), Matlab still uses the old code.

cur_dir = pwd();
project_dir = get_project_dir();
cd(project_dir)
restoredefaultpath
startup
cd(cur_dir)

end