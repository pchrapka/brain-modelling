function clean_data(stage)
%CLEAN_DATA removes data created at a specific stage and its derivatives
%
%   stage
%       name of stage to remove i.e. 'SM1snr0'

command = ['find . -type d -name ''*' stage '*'' -exec rm -rf {} \;'];

unix(command);

end