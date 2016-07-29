classdef MRI < ftb.AnalysisStep
    %MRI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        config;
        mri_mat;
        mri_segmented;
        mri_mesh;
    end
    
    methods
        function obj = MRI(params,name)
            %   params (struct or string)
            %       struct or file name
            %       including mri_data
            %   name(string)
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
            % set vars
            obj@ftb.AnalysisStep('MRI');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            % set previous step, aka none
            obj.prev = [];
            
            obj.mri_mat = '';
            obj.mri_segmented = '';
            obj.mri_mesh = '';
        end
        
        function obj = add_prev(obj,prev)
            %ADD_PREV add previous AnalysisStep
            %   ADD_PREV(prev) add previous AnalysisStep
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@isempty);
            parse(p,prev);
            
            % set the previous step, aka None
            obj.prev = p.Results.prev;
        end
        
        function obj = init(obj,analysis_folder)
            
            % parse inputs
            p = inputParser;
            addOptional(p,'analysis_folder','',@ischar);
            parse(p,analysis_folder);
            
            % check inputs
            if isempty(analysis_folder)
                error(['ftb:' mfilename],...
                    'please specify an output folder');
            end
            
            % create folder for analysis step, name accounts for dependencies
            out_folder = fullfile(analysis_folder, obj.get_name());
            if ~exist(out_folder,'dir')
                mkdir(out_folder)
            end
            
            % Set up file names
            % MRI data specific
            [~, mri_name, ~] = fileparts(obj.config.mri_data);
            obj.mri_mat = fullfile(out_folder, [mri_name '_mri.mat']);
            obj.mri_segmented = fullfile(out_folder, [mri_name '_mri_segmented.mat']);
            
            % Method specific
            obj.mri_mesh = fullfile(out_folder, 'mri_mesh.mat');
            
            % set the init flag
            obj.init_called = true;
            
            % load any files specified in the config
            obj.load_files();
        end
        
        function obj = process(obj)
            debug = false;
            
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % Read the MRI
            if ~exist(obj.mri_mat,'file')
                cfgin = [];
                cfgin.inputfile = obj.config.mri_data;
                cfgin.outputfile = obj.mri_mat;
                
                ft_read_mri_mat(cfgin);
            else
                fprintf('%s: skipping ft_read_mri_mat, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
            % Segment the MRI data
            if ~exist(obj.mri_segmented,'file')
                cfgin = obj.config.ft_volumesegment;
                cfgin.inputfile = obj.mri_mat;
                cfgin.outputfile = obj.mri_segmented;
                
                ft_volumesegment(cfgin);
            else
                fprintf('%s: skipping ft_volumesegment, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
            if obj.check_file(obj.mri_mesh)
                % Prep the mesh
                cfgin = obj.config.ft_prepare_mesh;
                cfgin.inputfile = obj.mri_segmented;
                % cfgin.outputfile = obj.mri_mesh; % forbidden
                
                mesh = ft_prepare_mesh(cfgin);
                save(obj.mri_mesh, 'mesh');
                
                % Check meshes
                if debug
                    for i=1:length(cfgin.tissue)
                        figure;
                        ft_plot_mesh(mesh(i),'facecolor','none'); %brain
                        title(cfgin.tissue{i});
                    end
                end
            else
                fprintf('%s: skipping ft_prepare_mesh, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
        
        function [pos,names] = get_mri_fiducials(obj)
            % extracts fiducials from mri
            
            % Load MRI data
            mri = ftb.util.loadvar(obj.mri_mat);
            fields = {'nas','lpa','rpa'};
            
            % get fiducials
            transm = mri.transform;
            for j=1:length(fields)
                coord = mri.hdr.fiducial.mri.(fields{j});
                coord = ft_warp_apply(transm, coord, 'homogenous');
                pos(j,:) = coord;
                names{j} = upper(fields{j});
            end
        end
        
        function plot(obj,elements)
            
            for i=1:length(elements)
                switch elements{i}
                    case 'fiducials'
                        hold on;
                        
                        % load fiducials
                        [pos,str] = obj.get_mri_fiducials();
                        style = 'or';
                        
                        % plot points
                        plot3(pos(:,1), pos(:,2), pos(:,3), style);
                        % plot labels
                        for j=1:size(pos,1)
                            text(pos(j,1), pos(j,2), pos(j,3), str{j});
                        end
                end
            end
                        
        end
    end
    
end

