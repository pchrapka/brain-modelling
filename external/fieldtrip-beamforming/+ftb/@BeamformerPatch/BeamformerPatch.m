classdef BeamformerPatch < ftb.Beamformer
    %BeamformerPatch Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % original ftb.Beamformer properties
        lf;  % leadfield Object with filters
        eeg; % eeg Object with modified timelock data
        patches; % patch file
    end
    
    methods (Static, Access = protected)
        [source, patches] = compute_lcmv_patch_filters(...
            data, leadfield, atlasfile, patches, varargin);
    end
    
    methods (Static)
        
        patches = get_basis(patches, leadfield, varargin);
        
        % function definitions for patch configurations
        patches = get_aal_coarse_13();
        patches = get_aal();
        
        function patches = get_patches(config_name)
            %GET_PATCHES returns list of patches based on a configuration
            %   GET_PATCHES(config_name) returns a list of patches based on
            %   a configuration
            %
            %   Input
            %   -----
            %   config_name (string)
            %       options:
            %       'aal'
            %       'aal-coarse-13'
            %
            %   Output
            %   ------
            %   see ftb.BeamformerPatch.get_aal,
            %   ftb.BeamformerPatch.get_aal_coarse_13
            
            switch config_name
                case 'aal-coarse-13'
                    patches = ftb.BeamformerPatch.get_aal_coarse_13();
                case 'aal'
                    patches = ftb.BeamformerPatch.get_aal();
                otherwise
                    error('unknown cortical patch config: %s\n',config_name);
            end     
        end
    end
    
    methods (Access = protected)
        obj = process_beamformer_patch(obj);
        
    end
    
    methods
        function obj = BeamformerPatch(params,name)
            %   params (struct or string)
            %       struct or file name
            %   name (string)
            %       object name
            %
            %   Config
            %   ------
            %   cortical_patches_name (string)
            %       name of cortical patch configuration 
            %       options: 
            %           aal-coarse-13
            %           aal
            
            % use Beamformer constructor
            obj@ftb.Beamformer(params,name);
            obj.prefix = 'BPatch';
            
            % double check config
            if ~isequal(obj.config.ft_sourceanalysis.method,'lcmv')
                error(['ftb:' mfilename],...
                    'only compatible with lcmv');
            end
            
            % create leadfield object
            obj.lf = ftb.Leadfield(obj.config,'patchfilt');
            obj.eeg = ftb.EEG(obj.config,'modtimelock');
            
            obj.patches = '';
        end
        
        function obj = init(obj,analysis_folder)
            %INIT initializes the output files
            %   INIT(analysis_folder)
            %
            %   Input
            %   -----
            %   analysis_folder (string)
            %       root folder for the analysis output
            
            % call Beamformer init on main object
            init@ftb.Beamformer(obj,analysis_folder);   
            
            % init Leadfield object
            obj.lf.init(obj.folder);
            obj.eeg.init(obj.folder);
            
            % init output folder and files
            properties = {'patches'};
            for i=1:length(properties)
                obj.(properties{i}) = obj.init_output(analysis_folder,...
                    'properties',properties{i});
            end
            
            obj.init_called = true;
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
            
            if ~isfield(obj.config,'cov_avg')
                obj.config.cov_avg = 'no';
            end
            
            if obj.check_file(obj.patches)
                % load data
                leadfield = ftb.util.loadvar(lfObj.leadfield);
                patches_list = ftb.BeamformerPatch.get_patches(...
                    obj.config.cortical_patches_name);
                
                % check for get_basis params
                if ~isfield(obj.config,'get_basis')
                    obj.config.get_basis = {};
                end
                % get the patch basis
                patches_list = ftb.BeamformerPatch.get_basis(...
                    patches_list, leadfield,...
                    obj.config.get_basis{:});
                
                % save patches
                save(obj.patches, 'patches_list');
            else
                fprintf('%s: skipping patches, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
            % modify timelock file if cov_avg option set
            if isequal(obj.config.cov_avg,'yes')
                % use average covariance of all trials to compute one
                % filter
                if obj.check_file(obj.eeg.timelock)
                    timelock = ftb.util.loadvar(eegObj.timelock);
                    
                    [out_folder,~,~] = fileparts(obj.eeg.timelock);
                    data = [];
                    fake_file = fullfile(out_folder, 'fake.mat');
                    save(fake_file,'data');
                    
                    obj.eeg.load_file('definetrial',fake_file);
                    obj.eeg.load_file('redefinetrial',fake_file);
                    obj.eeg.load_file('preprocessed',fake_file);
                    
                    if isfield(timelock, 'cov') && length(size(timelock.cov))==3
                        ntrials = size(timelock.cov,1);
                    elseif isfield(timelock, 'trial') && length(size(timelock.trial))==3
                        ntrials = size(timelock.trial,1);
                    else
                        ntrials = 1;
                        error('requires multiple trials');
                    end
                    
                    fprintf('%s: averaging cov from trials\n',strrep(class(obj),'ftb.',''));
                    % modify timelock
                    % average the single-trial covariance matrices
                    data = squeeze(mean(timelock.cov,1));
                    % copy the average covariance matrix for every individual trial
                    timelock.cov = repmat(data, [ntrials 1 1]);
                    
                    % save
                    save(obj.eeg.timelock, 'timelock');
                    
                else
                    fprintf('%s: skipping modified timelock, already exists\n',...
                        strrep(class(obj),'ftb.',''));
                end
            end
            
            % precompute filters
            if obj.check_file(obj.lf.leadfield)
                % load data
                
                leadfield = ftb.util.loadvar(lfObj.leadfield);
                patches_list = ftb.util.loadvar(obj.patches);
                if isequal(obj.config.cov_avg,'yes')
                    timelock = ftb.util.loadvar(obj.eeg.timelock);
                else
                    timelock = ftb.util.loadvar(eegObj.timelock);
                end

                if isequal(obj.config.cov_avg,'yes')
                    ndims_cov = length(size(timelock.cov));
                    if ndims_cov == 3
                        % choose one since they're all the same
                        timelock.cov = squeeze(timelock.cov(1,:,:));
                    end
                end
                
                % check for get_basis params
                if ~isfield(obj.config,'compute_lcmv_patch_filters')
                    obj.config.compute_lcmv_patch_filters = {};
                end
                    
                % compute filters
                data_filters = ftb.BeamformerPatch.compute_lcmv_patch_filters(...
                    timelock, leadfield, patches_list, obj.config.compute_lcmv_patch_filters{:});
                
                % save filters
                leadfield.filter = data_filters.filters;
                leadfield.filter_label = data_filters.patch_labels;
                leadfield.inside = data_filters.inside;
                save(obj.lf.leadfield, 'leadfield');
            else
                fprintf('%s: skipping compute_lcmv_patch_filters, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
            % source analysis
            % -----
            % process source analysis
            if isequal(obj.config.cov_avg,'yes')
                % use modified timelock
                obj.process_deps(obj.eeg,obj.lf,elecObj,hmObj);
            else
                obj.process_deps(eegObj,obj.lf,elecObj,hmObj);
            end
        end
        
        function plot_beampattern(obj,seed,varargin)
            %PLOT_BEAMPATTERN plots beampattern on anatomical image
            %   PLOT_BEAMPATTERN(obj, seed, ...)
            %   plots beampattern power on anatomical images. The
            %   beampattern is computed wrt a seed location and is
            %   represented by the Frobenius norm
            %
            %   Inputs
            %   ------
            %   seed (string or scalar)
            %       seed location for beampattern, you can specify an
            %       patch label or an index
            %
            %   Parameters
            %   ----------
            %   method (default = 'slice')
            %       plotting method: slice or ortho
            %   
            %   options (struct)
            %       options for ft_sourceplot, see ft_sourceplot
            
            % TODO refactor in plot_beampattern_deps and move to Beamformer
            % class
            
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'seed');
            parse(p,seed);
            
            % load leadfield
            leadfield = ftb.util.loadvar(obj.lf.leadfield);
            
            % find filter corresponding to the seed
            if ischar(p.Results.seed)
                % find a leadfield corresponding to the label
                match = lumberjack.strfindlisti(leadfield.filter_label', p.Results.seed);
                if ~any(match)
                    error('could not find %s', p.Results.seed);
                end
                filt_seed = leadfield.filter{find(match==1,1)};
            elseif isscalar(p.Results.seed)
                % use index
                filt_seed = leadfield.filter{p.Results.seed};
            else
                error(['ftb:' mfilename],...
                    'unknown seed type');
            end
            
            % create source struct
            source = [];
            source.dim = leadfield.dim;
            source.pos = leadfield.pos;
            source.inside = leadfield.inside;
            source.method = 'average';
            source.avg.pow = zeros(size(leadfield.inside));
            
            for i=1:length(leadfield.inside)
                if leadfield.inside(i)
                    source.avg.pow(i) = norm(filt_seed*leadfield.leadfield{i},'fro');
                end
            end
            
            % get MRI object
            mriObj = obj.get_dep('ftb.MRI');
            % load mri data
            mri = ftb.util.loadvar(mriObj.mri_mat);
            
            obj.plot_anatomical_deps(mri,source,varargin{:});
        end
        
        function plot_patch_resolution(obj,seed,varargin)
            %PLOT_PATCH_RESOLUTION plots patch resolution on anatomical image
            %   PLOT_PATCH_RESOLUTION(obj, seed, ...) plots patch
            %   resolution on anatomical images. The resolution is computed
            %   wrt a seed location and is represented by eq (14) of
            %   Limpiti2006
            %
            %   Inputs
            %   ------
            %   seed (string or scalar)
            %       seed patch, you can specify an patch label or an index
            %
            %   Parameters
            %   ----------
            %   method (default = 'slice')
            %       plotting method: slice or ortho
            %   
            %   options (struct)
            %       options for ft_sourceplot, see ft_sourceplot
            
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'seed');
            parse(p,seed);
            
            % load patches
            patches = ftb.util.loadvar(obj.patches);
            
            % find filter corresponding to the seed
            if ischar(p.Results.seed)
                % find a patch corresponding to the label
                match = lumberjack.strfindlisti({patches.name}, p.Results.seed);
                if ~any(match)
                    error('could not find %s', p.Results.seed);
                end
                U_seed = patches(match).U;
            elseif isscalar(p.Results.seed)
                % use index
                U_seed = patches(p.Results.see).U;
            else
                error(['ftb:' mfilename],...
                    'unknown seed type');
            end
            
            % load leadfield
            leadfield = ftb.util.loadvar(obj.lf.leadfield);
            
            % create source struct
            source = [];
            source.dim = leadfield.dim;
            source.pos = leadfield.pos;
            source.inside = leadfield.inside;
            source.method = 'average';
            source.avg.pow = zeros(size(leadfield.inside));
            
            for i=1:length(patches)
                H = patches(i).H;
                delta = trace(H'*(U_seed*U_seed')*H)/trace(H'*H);
                source.avg.pow(patches(i).inside) = delta;
            end
            
            % get MRI object
            mriObj = obj.get_dep('ftb.MRI');
            % load mri data
            mri = ftb.util.loadvar(mriObj.mri_mat);
            
            obj.plot_anatomical_deps(mri,source,varargin{:});
        end
        
    end
    
end

