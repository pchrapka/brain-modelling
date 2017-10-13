function [data_file,data_name,elec_file] = get_data_beta(subject_num,deviant_percent)
%GET_DATA_BETA function to retrieve data paths for Andrew's data
%   [data_file, data_name, elec_file] =
%       GET_DATA_BETA(subject_num,deviant_percent) 
%   function to retrieve data paths for Andrew's data
%
%   Input
%   -----
%   subject_num (integer)
%       subject number, ranges from 1-10
%   deviant_percent (integer)
%       percentage of deviant trials 10 or 20
%
%   Input
%   -----
%   subject_num (integer)
%       subject number, ranges from 1-10
%   deviant_percent (integer)
%       percentage of deviant trials 10 or 20
%
%   Output
%   ------
%   data_file (string)
%       absolute data file path
%   data_name (string)
%       data name string with the following form s[subject number]-[deviant
%       percent], ex. s03-10
%   elec_file (string)
%       electrode file with modified electrode names to be uniform in case

p = inputParser();
addRequired(p,'subject_num',@(x) x >= 1 && x <= 13);
addRequired(p,'deviant_percent',@(y) any(arrayfun(@(x) isequal(x,y), [10 20])) );
parse(p,subject_num,deviant_percent);

data_params = data_beta_config();
data_dir = data_params.data_dir;

data_file = fullfile(data_dir,sprintf('exp%02d_%d.bdf',subject_num,deviant_percent));
elec_file = fullfile(data_dir,sprintf('exp%02d_mod.sfp',subject_num));

if ~exist(elec_file,'file')
    % remove the hyphen in the electrode file to match the eeg header
    
    elec_file_orig = fullfile(data_dir,sprintf('exp%02d.sfp',subject_num));
    % open the original electrode file
    fid = fopen(elec_file_orig);
    % read the data
    elec_data = textscan(fid, '%s%f%f%f');
    fclose(fid);
    
    % remove the hyphen
    channels = cellfun(@(x) strrep(x,'-',''), elec_data{1},'UniformOutput',false);
    % save the new channel names
    elec_data{1} = channels;
    
    % write to a new file
    fid = fopen(elec_file,'w');
    nchannels = length(elec_data{1});
    for i=1:nchannels
        fprintf(fid,'%s\t%0.4f\t%0.4f\t%0.4f\n',...
            elec_data{1}{i},elec_data{2}(i),elec_data{3}(i),elec_data{4}(i));
    end
    fclose(fid);
end

data_name = sprintf('s%02d-%d',subject_num,deviant_percent);

end
