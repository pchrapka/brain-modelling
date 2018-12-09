classdef BeamformerRMV < ftb.Beamformer
    %BeamformerRMV Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % original ftb.Beamformer properties
        lf;  % leadfield Object with filters
        eeg; % eeg Object with modified timelock data
        verbosity = 0;
        solver = 'yalmip';
        eig_type = 'none';
        % options: 
        %    'eig pre cov'
        %    'eig pre leadfield'
        %    'eig post'
        %    'none'
        n_interfering_sources = 0;
        epsilon = 0;
        
        aniso = false;
        aniso_mode = 'normal';
        radius = [];
        multiplier = 0.1;
        c = 20;
        var_percent = 0;
    end
    
    methods (Access = protected)
        source = compute_rmv_filters(...
            obj, data, leadfield, varargin);
    end
    
    methods (Access = protected)
        obj = process_beamformer_patch(obj);
        
    end
    
    methods
        function obj = BeamformerRMV(params,name)
            %   params (struct or string)
            %       struct or file name
            %   name (string)
            %       object name
            %
            %   Parameters
            %   ----------
            %   verbosity (integer, default = 0)
            %       verbosity level
            %
            %   Isotropic RMVB
            %   --------------
            %   default beamformer
            %
            %   epsilon (double, default = 0)
            %       level of uncertainty in leadfield matrix, used to
            %       compute A = sqrt(epsilon^2/3) * I
            %
            %   Anisotropic RMVB
            %   ----------------
            %   aniso (logical, default = false)
            %       selects anisotropic RMVB
            %
            %   aniso_mode (string, default = 'normal')
            %       select anisotropic RMVB mode, options include: normal,
            %       random, radius
            %
            %       normal - uses a specific definition of the uncertainty
            %       model. Optional parameter c.
            %       random - generaters the uncertainty matrix with a
            %       random perturbation. Requires var_percent parameter
            %       radius - generates the uncertainty matrix from the
            %       covariance computed from nearby points in the estimated
            %       head model. Requires radius parameter
            %
            %   multiplier (double, default = 0.1)
            %       Multiple of principle error component used to specify
            %       uncertainty matrix. Used when aniso_mode = 'normal'
            %
            %   c (double, default = 20)
            %       upper bound on uncertainty for normal aniso
            %
            %   var_percent (double, default = 0)
            %       sets variance for anisotropic RMVB when aniso_mode =
            %       'random'. the variance is specified as a percent, which
            %       will correspond to the percent of the norm of the
            %       leadfield matrix.
            %
            %   radius (integer, default = [])
            %       radius around point in mm
            %
            %   Eigenspace RMVB (anisotropic/isotropic)
            %   ---------------
            %   eigenspace (string, default = 'none')
            %       selects an eigenspace beamformer
            %       options: 'eig pre cov', 'eig pre leadfield', 'eig
            %       post', 'none'
            %
            %       FIXME explain each one
            %   ninterference (integer, default = 0)
            %       number of interfering sources for eigenspace beamformer
            
            % use Beamformer constructor
            obj@ftb.Beamformer(params,name);
            obj.prefix = 'BFRMV';
            
            % double check config
            if ~isequal(obj.config.ft_sourceanalysis.method,'lcmv')
                error(['ftb:' mfilename],...
                    'only compatible with lcmv');
            end
            
            fields = {'verbosity'};
            for i=1:length(fields)
                field = fields{i};
                if isfield(obj.config.BeamformerRMV, field)
                    obj.(field) = obj.config.BeamformerRMV.(field);
                end
            end
            
            % create leadfield object
            obj.lf = ftb.Leadfield(obj.config,'filters');
            obj.eeg = ftb.EEG(obj.config,'modtimelock');
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
            
            % modify timelock file if cov_avg option set
            if isequal(obj.config.cov_avg,'yes')
                % use average covariance of all trials to compute one
                % filter
                if obj.check_file(obj.eeg.timelock)
                    timelock = ftb.util.loadvar(eegObj.timelock);
                                        
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
                    data = mean(timelock.cov,1);
                    % copy the average covariance matrix for every individual trial
                    timelock.cov = repmat(data, [ntrials 1 1]);
                    
                    % save
                    save(obj.eeg.timelock, 'timelock','-v7.3');
                    
                else
                    fprintf('%s: skipping modified timelock, already exists\n',...
                        strrep(class(obj),'ftb.',''));
                end
            end
            
            % precompute filters
            if obj.check_file(obj.lf.leadfield)
                % load data
                
                leadfield = ftb.util.loadvar(lfObj.leadfield);
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
                if ~isfield(obj.config,'compute_rmv_filters')
                    obj.config.compute_rmv_filters = {};
                end
                    
                % compute filters
                data_filters = ftb.BeamformerRMV.compute_rmv_filters(...
                    timelock, leadfield, obj.config.compute_rmv_filters{:});
                
                % save filters
                leadfield.filter = data_filters.filters;
                leadfield.inside = data_filters.inside;
                save(obj.lf.leadfield, 'leadfield');
            else
                fprintf('%s: skipping compute_rmv_filters, already exists\n',...
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
    end
end

