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
                patches = ftb.patches.get_aal_coarse(obj.config.atlas_file);
                % FIXME this shouldn't be so specific
                
                % get the patch basis
                if ~isfield(obj.config,'ftb_patches_basis')
                    obj.config.ftb_patches_basis = {};
                end
                patches = ftb.patches.basis(patches, leadfield,...
                    obj.config.ftb_patches_basis{:});
                
                % save patches
                save(obj.patches, 'patches');
            else
                fprintf('%s: skipping ftb.patches.basis, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
            if obj.check_file(obj.sourceanalysis)
                % load data
                patches = ftb.util.loadvar(obj.patches);
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
                    
                ntrials = size(timelock_all.trialinfo,1);
                parfor i=1:ntrials
                    % trial
                    % -------
                    
                    % select data for one trial
                    timelock = timelock_all;
                    timelock.dimord = 'chan_time';
                    timelock.trial = squeeze(timelock_all.trial(i,:,:));
                    timelock.cov = squeeze(timelock_all.cov(i,:,:));
                    timelock.trialinfo = timelock_all.trialinfo(i,:);
                    
                    % save
                    tmp_timelock_file = [tempname '.mat'];
                    save_parfor(tmp_timelock_file, timelock);
                   
                    % load timelock data into ftb.EEG object
                    eegtrialObj.load_file('timelock', tmp_timelock_file);
                    
                    % filters
                    % -------
                    % copy leadfield
                    leadfield_cpy = leadfield;
                    
                    % computer filters
                    % NOTE if mode == 'all' each source struct takes up a
                    % few MBs, if there are 1000 trials, that's a few GBs
                    source = ftb.BeamformerPatch.beamformer_lcmv_patch(...
                        timelock, leadfield_cpy, patches,'mode','single');
                    
                    % save filters
                    leadfield_cpy.filter = source.filters;
                    leadfield_cpy.filter_label = source.patch_labels;
                    leadfield_cpy.inside = source.inside;
                    save_parfor(obj.lf.leadfield,leadfield_cpy);
                    
                    % source analysis
                    % -------
                    % process source analysis
                    obj.process_deps(eegtrialObj,obj.lf,elecObj,hmObj);
                    
                    % concatenate results into data struct
%                     if i == 1    
%                         % allocate mem
%                         data = ftb.util.loadvar(obj.sourceanalysis);
%                         data = rmfield(data,'cfg'); % takes up a lot of memory
%                         sourceanalysis_all(ntrials) = data;
%                     end
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
                save(obj.sourceanalysis, 'sourceanalysis_all');
            else
                fprintf('%s: skipping ft_sourceanalysis, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
        end
    end
    
end

