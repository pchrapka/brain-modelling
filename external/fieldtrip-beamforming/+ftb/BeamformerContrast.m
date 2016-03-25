classdef BeamformerContrast < ftb.Beamformer
    %BeamformerContrast Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pre;        % ftb.Beamformer
        post;       % ftb.Beamformer
        % original ftb.Beamformer properties - describes contrast
    end
    
    methods
        function obj = BeamformerContrast(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % use Beamformer constructor
            obj@ftb.Beamformer(params,name);
            obj.prefix = 'BC';
            
            % create pre, post objects, 
            % use the same filter configurations
            obj.pre = ftb.Beamformer(obj.config,'pre');
            obj.post = ftb.Beamformer(obj.config,'post');
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Beamformer'));
            parse(p,prev);
            
            % set the previous step
            obj.prev = p.Results.prev;
            obj.pre.prev = p.Results.prev;
            obj.post.prev = p.Results.prev;
        end
        
        function obj = init(obj,out_folder)
            
            % call Beamformer init on main object
            init@ftb.Beamformer(obj,out_folder);
            
            % create folder for analysis step, name accounts for dependencies
            out_folder2 = fullfile(out_folder, obj.get_name());
            if ~exist(out_folder2,'dir')
                mkdir(out_folder2)
            end        
            
            % init Beamformer objects
            obj.pre.init(out_folder2);
            obj.post.init(out_folder2);
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % get Beamformer common
            bfObj = obj.get_dep('ftb.Beamformer');
            if isempty(bfObj)
                error(['ftb:' mfilename],...
                        'missing ftb.Beamformer step');
            end
            
            % check if it contains grid.filter
            bfcommon = ftb.util.loadvar(bfObj.sourceanalysis);
            if ~isfield(bfcommon.avg,'filter')
                error(['ftb:' mfilename],...
                        'missing filter in ftb.Beamformer step, use keepfilter option');
            end
            % set common filters for pre and post data
            obj.pre.config.ft_sourceanalysis.grid.filter = bfcommon.avg.filter;
            obj.post.config.ft_sourceanalysis.grid.filter = bfcommon.avg.filter;
            
            % get EEGPrePost
            eegObj = obj.get_dep('ftb.EEGPrePost');
            if isempty(eegObj)
                error(['ftb:' mfilename],...
                        'missing ftb.EEGPrePost step');
            end
            
            % get common deps
            lfObj = obj.get_dep('ftb.Leadfield');
            elecObj = obj.get_dep('ftb.Electrodes');
            hmObj = obj.get_dep('ftb.Headmodel');
            
            % source analysis
            obj.pre.process_deps(eegObj.pre,lfObj,elecObj,hmObj);
            obj.post.process_deps(eegObj.post,lfObj,elecObj,hmObj);

            % contrast
            if obj.check_file(obj.sourceanalysis)
                
                % load sourceanalysis data
                bfpre = ftb.util.loadvar(obj.pre.sourceanalysis);
                bfpost = ftb.util.loadvar(obj.post.sourceanalysis);
                
                fprintf('%s: contrasting: %s / %s\n',...
                    strrep(class(obj),'ftb.',''),...
                    [obj.post.prefix obj.post.name], ...
                    [obj.pre.prefix obj.pre.name]);
                
                % create output struct
                data = bfpost;
                if isfield(data.avg,'mom')
                    data.avg = rmfield(data.avg,'mom');
                end
                
                % contrast the source analysis
                data.avg.pow = (bfpost.avg.pow - bfpre.avg.pow)./bfpre.avg.pow;
                
                save(obj.sourceanalysis,'data');
            else
                fprintf('%s: skipping ft_sourceanalysis, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
    end
    
end

