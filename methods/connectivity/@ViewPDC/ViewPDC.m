classdef ViewPDC < handle
    %ViewPDC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        w;
        pdc_sig_file;
    end
    
    properties (SetAccess = protected)
        pdc;
        pdc_sig;
        file;
        fs;
        info;
        time;
        
        save_tag; % save tag for each plot type
        filepath;
        filename;
        outdir;
    end
    
    properties (Dependent)
        freq_tag; % freq tag for saving
    end
    
    methods
        function obj = ViewPDC(file,varargin)
            
            p = inputParser();
            addRequired(p,'file',@ischar);
            addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2));
            addParameter(p,'fs',1,@isnumeric);
            addParameter(p,'info',[],@(x) isa(x,'ChannelInfo'));
            addParameter(p,'time',[],@isnumeric);
            addParameter(p,'outdir','data',@ischar);
            parse(p,file,varargin{:});
            
            if p.Results.w(1) < 0 || p.Results.w(2) > 0.5
                disp(p.Results.w);
                error('w range too wide, should be between [0 0.5]');
            end
            
            obj.pdc = [];
            obj.file = file;
            [obj.filepath,obj.filename,~] =  fileparts(obj.file);
            obj.w = p.Results.w;
            obj.fs = p.Results.fs;
            obj.time = p.Results.time;
            obj.info = p.Results.info;
            
            obj.save_tag = [];
            if isequal(p.Results.outdir,'data')
                obj.outdir = obj.filepath;
            end
        end
        
        function set.w(obj,value)
            p = inputParser();
            addRequired(p,'w',@(x) length(x) == 2 && isnumeric(2));
            parse(p,value);
            
            if p.Results.w(1) < 0 || p.Results.w(2) > 0.5
                disp(p.Results.w);
                error('w range too wide, should be between [0 0.5]');
            end
            
            obj.w = value;
        end
        
        function value = get.freq_tag(obj)
            value = sprintf('-%0.4f-%0.4f',obj.w(1),obj.w(2)); 
        end
        
        function unload(obj)
            obj.pdc = [];
        end
        
        function load(obj,property)
            switch property
                case 'pdc'
                    if isempty(obj.pdc)
                        print_msg_filename(obj.file,'loading');
                        data = loadfile(obj.file);
                        obj.pdc = data.pdc;
                        
                        dims = size(obj.pdc);
                        ndims = length(dims);
                        if ndims ~= 4
                            obj.pdc = [];
                            error('requires dynamic pdc data');
                        end
                    end
                case 'pdc_sig'
                    if isempty(obj.pdc_sig)
                        if isempty(obj.pdc_sig_file)
                            error('missing pdc_sig_file');
                        end
                        print_msg_filename(obj.pdc_sig_file,'loading');
                        data = loadfile(obj.pdc_sig_file);
                        obj.pdc_sig = data.pdc;
                        
                        % pdc sig needs to be same size as pdc
                        dims = size(obj.pdc_sig);
                        if ~isequal(dims, size(obj.pdc))
                            obj.pdc_sig = [];
                            error('significant pdc is not the same size as pdc');
                        end
                    end
 
                otherwise
                    error('unknown property %s',property);
            end
        end
        
        function save_plot(obj,varargin)
            %   Parameters
            %   ----------
            %   outdir (string, default = pwd)
            %       output directory
            %       by default uses output directory set in ViewPDC.outdir,
            %       can be overriden here with:
            %       1. 'data' - same directory where data is located
            %       2. any regular path
            %   save (logical, default = false)
            %       flag to save figure
            
            p = inputParser();
            addParameter(p,'save',false,@islogical);
            addParameter(p,'outdir','',@ischar);
            addParameter(p,'engine','export_fig',...
                @(x) any(validatestring(x,{'export_fig','matlab'})));
            parse(p,varargin{:});
            
            if p.Results.save
                outdir = obj.get_outdir(p.Results.outdir);
                outfile = obj.get_savefile();
                
                % save
                save_fig2('path',outdir,'tag', outfile,'engine',p.Results.engine);
                
                % clear save tag
                obj.save_tag = [];
            end
        end
        
        % plot functions
        plot_single(obj,chj,chi);
        plot_single_largest(obj,varargin);
        plot_single_multiple(obj,chj,chi,varargin)
        plot_summary(obj,varargin);
        plot_tiled(obj);
        
        plot_adjacency(obj,varargin);
        plot_directed(obj,varargin)
        created = plot_seed(obj,chseed,varargin)
        
        % summary function
        out = get_summary(obj,varargin)
        print_summary(obj,varargin)
        
    end
    
    methods (Access = protected)
        function fresh = check_pdc_freshness(obj,newfile)
            % checks PDC data file timestamp vs the newfile timestamp
            fresh = false;
            if exist(newfile,'file')
                data_time = get_timestamp(obj.file);
                new_time = get_timestamp(newfile);
                if data_time > new_time
                    fresh = true;
                end
            end
        end
        
        function outfile = get_savefile(obj)
            % returns the output file name
            if isempty(obj.save_tag)
                error('save tag not set in plot function');
            end
            
            outfile = [obj.filename obj.save_tag obj.freq_tag];
        end
        
        function outdir = get_outdir(obj,value)
            % returns the output directory
            
            if isempty(value)
                if isempty(obj.outdir)
                    outdir = pwd;
                    warning('no output directory specified\nusing default %s',outdir);
                else
                    outdir = obj.outdir;
                end
            elseif isequal(value,'data');
                outdir = obj.filepath;
            else
                outdir = value;
                if ~exist(outdir,'dir')
                    mkdir(outdir);
                end
            end
            
        end
        
        function check_info(obj)
            % checks channel info
            
            if isempty(obj.info)
                % add generic channel labels if none exist
                nchannels = size(obj.pdc,2);
                labels = cell(nchannels,1);
                for i=1:nchannels
                    labels{i} = sprintf('%d',i);
                end
                obj.info = ChannelInfo(labels);
            end
        end
        
        function idx = sort_channels(obj)
            % sort by hemisphere, region, angle
            
            sort_method = [];
            group_data = [];
            
            if ~isempty(obj.info.coord)
                % sort coordinates according to angle around origin
                angles = atan2(obj.info.coord(:,2),obj.info.coord(:,1));
                
                sort_method = 1;
                group_data = angles(:);
            end
            
            if ~isempty(obj.info.region_order)
                % add region order sort info
                group_data = [group_data obj.info.region_order(:)];
                ncol = size(group_data,2);
                sort_method = [ncol sort_method];
            end
            
            if ~isempty(obj.info.hemisphere_order)
                % add hemisphere order sort info
                group_data = [group_data obj.info.hemisphere_order(:)];
                ncol = size(group_data,2);
                sort_method = [ncol sort_method];
            end
            
            if isempty(group_data)
                % nothing to sort
                idx = 1:length(obj.info.label);
            else
                [~,idx] = sortrows(group_data,sort_method);
            end
            
            if ~isempty(obj.info.hemisphere)
                % NOTE assumes hemisphere label is Left or Right
                % flip left side so that front is at the top
                idx_left = cellfun(@(x) ~isempty(x),...
                    strfind(obj.info.hemisphere(idx),'Left'),'UniformOutput',true);
                idx_left_sorted = idx(idx_left);
                idx_left_sorted = flipdim(idx_left_sorted,1);
                idx(idx_left) = idx_left_sorted;
            end
        end
        
        function add_time_ticks(obj,axis)
            % add time ticks to the selected x or y axis
            
            if isempty(obj.time)
                fprintf('time is empty\n');
                return;
            end
            
            % find zero index
            temp = obj.time >= 0;
            zero_idx = find(temp,1,'first');
            if isempty(zero_idx)
                zero_idx = 1;
            end
            ticks = zero_idx;
            
            nticks = 5;
            % compute increment
            range = max(obj.time) - min(obj.time);
            order = floor(log10(range));
            increment = 10^order/nticks;
            % get number of points per increment
            npointspertick = ceil(increment/(obj.time(2) - obj.time(1)));
            % create the ticks
            extra_idx = -nticks:1:nticks;
            extra_idx = extra_idx*npointspertick + zero_idx;
            % remove ticks outside of range
            extra_idx = extra_idx(extra_idx > 0 & extra_idx < length(obj.time));
            % add zero tick
            ticks = [ticks extra_idx];
            % get unique and sort
            ticks = sort(unique(ticks));
            
            % create ticklabels
            ticklabels = cell(length(ticks),1);
            for i=1:length(ticks)
                % get time for each tick and convert to seconds
                ticklabels{i} = sprintf('%0.0fms',obj.time(ticks(i))*1000);
            end
            
            switch axis
                case 'x'
                    set(gca,'XTick', ticks, 'XTickLabel', ticklabels);
                case 'y'
                    set(gca,'YTick', ticks, 'YTickLabel', ticklabels);
            end
        end
        
        function add_vert_line(obj,time)
            if isempty(obj.time)
                fprintf('time is empty\n');
                return;
            end
            
            if time < obj.time(1) || time > obj.time(end)
                error('time is out of range');
            end
            
            [~,idx] = min(abs(time - obj.time));
            x(1) = idx;
            x(2) = idx;
            yl = ylim;
            y(1) = yl(1);
            y(2) = yl(2);
            
            hold on;
            plot(x,y,'--k','LineWidth',2);
        end
        
        function hxlabel = labelitx(obj,j) 
            % Labels x-axis plottings
            
            hxlabel = xlabel(obj.info.label{j});
            set(hxlabel,'FontSize',12);
        end
        
        function hylabel = labelity(obj,i) 
            % Labels y-axis plottings
            
            hylabel = ylabel(obj.info.label{i});
            set(hylabel,'FontSize',12);
        end
        
        function colors = get_region_cmap(obj,cmap_name)
            colors = [];
            if ~isempty(obj.info.region_order)
                % get colormap without changing the current one
                cmap_cur = colormap();
                cmap = colormap(cmap_name);
                colormap(cmap_cur);
                
                % set up colors
                max_regions = max(obj.info.region_order);
                ncolors = size(cmap,1);
                % convert region to pecentage
                region_pct = obj.info.region_order/max_regions;
                % get color index in cmap
                color_idx = ceil(ncolors*region_pct);
                % get colors for each region
                colors = cmap(color_idx,:);
            end
        end
    end
end

