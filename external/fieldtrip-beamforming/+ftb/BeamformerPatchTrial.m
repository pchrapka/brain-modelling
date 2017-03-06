classdef BeamformerPatchTrial < ftb.BeamformerPatch
    %BeamformerPatchTrial Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = BeamformerPatchTrial(params,name)
            %   params (struct or string)
            %       struct or file name
            %   name (string)
            %       object name
            
            obj@ftb.BeamformerPatch(params,name);
            obj.prefix = 'BPatchTrial';
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % get analysis step objects
            eegObj = obj.get_dep('ftb.EEG');
            lfObj = obj.get_dep('ftb.Leadfield');
            elecObj = obj.get_dep('ftb.Electrodes');
            hmObj = obj.get_dep('ftb.Headmodel');
            
            if obj.check_file(obj.patches)
                % load data
                leadfield = ftb.util.loadvar(lfObj.leadfield);
                patch_model = PatchModel(obj.config.PatchModel{:});
                
                % get the patch basis
                patch_model.get_basis(leadfield);
                
                % save patches
                save(obj.patches, 'patch_model');
            else
                fprintf('%s: skipping patches, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
            if obj.check_file(obj.sourceanalysis)
                % load data
                patch_model = ftb.util.loadvar(obj.patches);
                leadfield = ftb.util.loadvar(lfObj.leadfield);
                timelock_all = ftb.util.loadvar(eegObj.timelock);
                
                % check size of timelock
                dims = size(timelock_all.trial);
                if length(dims) ~= 3
                    error(['ftb:' mfilename],...
                        'missing a dimension, set keeptrials = yes for ft_timelockanalysis');
                end
                
                [out_folder,~,~] = fileparts(obj.sourceanalysis);
                
                % create EEG object for trial
                params = [];
                params.ft_definetrial = [];
                fake_file = fullfile(out_folder, 'fake.mat');
                save(fake_file,'params');
                eegtrialObj = ftb.EEG(params,'');
                eegtrialObj.init(out_folder);
                eegtrialObj.load_file('definetrial',fake_file);
                eegtrialObj.load_file('preprocessed',fake_file);
                
                % temporarily change the sourceanalysis file 
                source_all_file = obj.sourceanalysis;
                obj.sourceanalysis = strrep(obj.sourceanalysis,'.mat','-trial.mat');
                    
                ntrials = size(timelock_all.trial,1);
                for i=1:ntrials
                    % trial
                    % -------
                    
                    % select data for one trial
                    timelock = keepfields(timelock_all,{'time','dof','label','cfg'});
                    timelock.avg = squeeze(timelock_all.trial(i,:,:));
                    timelock.var = zeros(size(timelock_all.var));
                    timelock.dimord = 'chan_time';
                    timelock.cov = squeeze(timelock_all.cov(i,:,:));
                    %if isfield(timelock,'trialinfo')
                    %    timelock.trialinfo = timelock_all.trialinfo(i,:);
                    %end
                    
                    % should look like this
                    %        avg: [128x1434 double]
                    %        var: [128x1434 double]
                    %       time: [1x1434 double]
                    %        dof: [128x1434 double]
                    %      label: {128x1 cell}
                    %     dimord: 'chan_time'
                    %        cov: [128x128 double]
                    %        cfg: [1x1 struct]
                    
                    % save
                    tmp_timelock_file = fullfile(out_folder,'temp.mat');
                    save(tmp_timelock_file, 'timelock');
                   
                    % load timelock data into ftb.EEG object
                    eegtrialObj.load_file('timelock', tmp_timelock_file);
                    
                    % filters
                    % -------
                    % computer filters
                    % NOTE if mode == 'all' each source struct takes up a
                    % few MBs, if there are 1000 trials, that's a few GBs
                    data_filters = ftb.BeamformerPatch.compute_lcmv_patch_filters(...
                        timelock, leadfield, patch_model,'mode','single');
                    
                    % save filters
                    leadfield.filter = data_filters.filters;
                    leadfield.filter_label = data_filters.patch_labels;
                    leadfield.patch_centroid = data_filters.patch_centroid;
                    leadfield.inside = data_filters.inside;
                    save(obj.lf.leadfield, 'leadfield');
                    
                    % source analysis
                    % -------
                    % process source analysis
                    obj.process_deps(eegtrialObj,obj.lf,elecObj,hmObj);
                    
                    % concatenate results into data struct
                    if i == 1    
                        % allocate mem
                        data = ftb.util.loadvar(obj.sourceanalysis);
                        data = rmfield(data,'cfg'); % takes up a lot of memory
                        sourceanalysis_all(ntrials) = data;
                    end
                    data = ftb.util.loadvar(obj.sourceanalysis);
                    data = rmfield(data,'cfg'); % takes up a lot of memory
                    sourceanalysis_all(i) = data;
                    
                    % delete temp files
                    if exist(obj.sourceanalysis,'file')
                        delete(obj.sourceanalysis);
                    end
                    if exist(eegtrialObj.timelock,'file')
                        delete(eegtrialObj.timelock);
                    end
                end
                
                % save all sourceanalyses
                obj.sourceanalysis = source_all_file;
                save(obj.sourceanalysis, 'sourceanalysis_all','-v7.3');
            else
                fprintf('%s: skipping ft_sourceanalysis, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
        end
    end
    
end

