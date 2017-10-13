classdef DataBeta < handle
    %DataBeta class containing meta data for a subject's data set from
    %Andrew's beta study
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        subject = 0;
        deviant_percent = 0;
        
        data_dir = '';
        
        data_file = '';
        % absolute data file path
        data_name = '';
        % data name string with the following form s[subject number]-[deviant
        % percent], ex. s03-10
        
        elec_file = '';
        % electrode file with modified electrode names to be uniform in case
        
        elecbad_file = '';
        % file with bad electrode names
        elecbad_channels = {};
        % cell array of bad channels
        
        dipole_file = '';
        dipole_left = [];
        dipole_right = [];
    end
    
    methods
        function obj = DataBeta(subject_num,deviant_percent)
            %DATABETA contains meta data for Andrew's data sets
            %   DATABETA(subject_num,deviant_percent) creates DataBeta
            %   object that contains meta data for a specific data set from
            %   Andrew's beta study
            %
            %   Input
            %   -----
            %   subject_num (integer)
            %       subject number, ranges from 1-10
            %   deviant_percent (integer)
            %       percentage of deviant trials 10 or 20
            
            p = inputParser();
            addRequired(p,'subject_num',@(x) x >= 1 && x <= 13);
            addRequired(p,'deviant_percent',@(y) any(arrayfun(@(x) isequal(x,y), [10 20])) );
            parse(p,subject_num,deviant_percent);
            
            obj.subject = subject_num;
            obj.deviant_percent = deviant_percent;
            
            data_params = data_beta_config();
            obj.data_dir = data_params.data_dir;
            
            obj.data_file = fullfile(obj.data_dir,...
                sprintf('exp%02d_%d.bdf',subject_num,deviant_percent));
            obj.data_name = sprintf('s%02d-%d',subject_num,deviant_percent);
            obj.elec_file = fullfile(obj.data_dir,sprintf('exp%02d_mod.sfp',subject_num));
            
            obj.elec_file_setup();
        end
        
%         function value = get.elecbad_channels(obj)
%             if isempty(obj.elecbad_file)
%                 obj.get_bad_channels();
%             end
%             value = obj.elecbad_channels;
%         end
%         
%         function value = get.dipole_left(obj)
%             if isempty(obj.dipole_file)
%                 obj.get_dipoles();
%             end
%             value = obj.dipole_left;
%         end
%         
%         function value = get.dipole_right(obj)
%             if isempty(obj.dipole_file)
%                 obj.get_dipoles();
%             end
%             value = obj.dipole_right;
%         end
        
        function obj = load_dipoles(obj)
            
            obj.dipole_file = strrep(obj.data_file,'.bdf','_dipoles.txt');
            
            flag_missing = false;
            
            if exist(obj.dipole_file,'file')
                fid = fopen(obj.dipole_file);
                data = textscan(fid,'%s%f%f%f','HeaderLines',1);
                fclose(fid);
                
                nrows = length(data{1});
                for i=1:nrows
                    switch lower(data{1}{i})
                        case 'left'
                            obj.dipole_left = [data{2}(i) data{3}(i) data{4}(i)];
                        case 'right'
                            obj.dipole_right = [data{2}(i) data{3}(i) data{4}(i)];
                        otherwise
                    end
                end
                if any(isnan(obj.dipole_left))
                    flag_missing = true;
                    obj.dipole_left = [];
                end
                if any(isnan(obj.dipole_right))
                    flag_missing = true;
                    obj.dipole_right = [];
                end
            else
                flag_missing = true;
            end
            
            if flag_missing
                % create new file
                fid = fopen(obj.dipole_file,'w+');
                fprintf(fid,'Side X Y Z\n');
                fprintf(fid,'Left\n');
                fprintf(fid,'Right\n');
                fclose(fid);
                
                dipole_file_orig = strrep(obj.data_file,'.bdf','_av.bsa');
                
                error([mfilename ':MissingData'],...
                    ['add dipoles by following these steps\n\n'...
                    '1. open this file: %s\n'...
                    '2. add each dipole (make sure units are mm) to this file: %s\n'...
                    '3. rerun the function'],dipole_file_orig,obj.dipole_file);
                
            end
            
        end
        
        function obj = load_bad_channels(obj) 
            
            % set up file name
            obj.elecbad_file = strrep(obj.data_file,'bdf','bad');
            
            if exist(obj.elecbad_file,'file')
                fid = fopen(obj.elecbad_file);
                data = textscan(fid,'%s');
                fclose(fid);
                
                obj.elecbad_channels = data{1};
                
                % remove the first one
                obj.elecbad_channels(1) = [];
                % remove hyphens
                obj.elecbad_channels = cellfun(@(x) strrep(x,'-',''),...
                    obj.elecbad_channels,'UniformOutput',false);
            else
                warning([mfilename ':MissingData'],'missing bad channels');
                
                % create new file
                fid = fopen(obj.elecbad_file,'w+');
                fprintf(fid,'Header\n');
                fclose(fid);
                
                cfg_temp = [];
                cfg_temp.dataset = obj.data_file;
                ft_databrowser(cfg_temp);
                
                error([mfilename ':MissingData'],...
                    ['check for bad channels and follow these steps\n\n'...
                    '1. open this file: %s\n'...
                    '2. add bad channels, one per line\n'...
                    '3. rerun the function'],obj.elecbad_file);
            end
        end
    end
    
    methods (Access = private)
        function obj = elec_file_setup(obj)
            % set up elec_file
            if ~exist(obj.elec_file,'file')
                % remove the hyphen in the electrode file to match the eeg header
                
                elec_file_orig = fullfile(obj.data_dir,sprintf('exp%02d.sfp',obj.subject));
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
                fid = fopen(obj.elec_file,'w');
                nchannels = length(elec_data{1});
                for i=1:nchannels
                    fprintf(fid,'%s\t%0.4f\t%0.4f\t%0.4f\n',...
                        elec_data{1}{i},elec_data{2}(i),elec_data{3}(i),elec_data{4}(i));
                end
                fclose(fid);
            end
        end
    end
    
end

