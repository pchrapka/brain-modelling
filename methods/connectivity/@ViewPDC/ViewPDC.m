classdef ViewPDC < handle
    %ViewPDC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        file_pdc = {};
        file_pdc_sig;
    end
    
    properties (SetAccess = protected)
        w;
        f;
        
        pdc = [];
        pdc_nfreqs = [];
        pdc_loaded = '';
        pdc_sig;
        fs;
        info;
        time;
        nchannels;
        
        save_tag; % save tag for each plot type
        outdir;
        outdir_type;
        
        file_pdc_mean = '';
        file_pdc_var = '';
        file_pdc_std = '';
        file_idx = 1;
    end
    
    properties (Dependent)
        freq_tag; % freq tag for saving
        filepath;
        filename;
    end
    
    methods
        function obj = ViewPDC(varargin)
            
            p = inputParser();
            addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2));
            addParameter(p,'fs',1,@isnumeric);
            addParameter(p,'info',[],@(x) isa(x,'ChannelInfo'));
            addParameter(p,'time',[],@isnumeric);
            addParameter(p,'outdir','data',@ischar);
            parse(p,varargin{:});
            
            if p.Results.w(1) < 0 || p.Results.w(2) > 0.5
                disp(p.Results.w);
                error('w range too wide, should be between [0 0.5]');
            end
            
            obj.pdc = [];
            obj.w = p.Results.w;
            obj.fs = p.Results.fs;
            obj.time = p.Results.time;
            obj.info = p.Results.info;
            
            obj.save_tag = [];
            if isequal(p.Results.outdir,'data')
                obj.outdir_type = 'data';
            else
                obj.outdir_type = 'custom';
                obj.outdir = p.Results.outdir;
            end
        end
        
        function set.file_pdc(obj,value)
            p = inputParser();
            addRequired(p,'file_pdc',@iscell);
            parse(p,value);
            
            obj.unload();
            obj.file_pdc = p.Results.file_pdc;
        end
        
        function value = get.filepath(obj)
            if isempty(obj.file_pdc)
                error('file_pdc is empty');
            end
            [value,~,~] = fileparts(obj.file_pdc{obj.file_idx});
        end
        
        function value = get.filename(obj)
            if isempty(obj.file_pdc)
                error('file_pdc is empty');
            end
            [~,value,~] = fileparts(obj.file_pdc{obj.file_idx});
        end
        
        function set_freqrange(obj,value,varargin)
            p = inputParser();
            addRequired(p,'value',@(x) length(x) == 2 && isnumeric(x));
            addParameter(p,'type','f',@(x) any(validatestring(x,{'f','w'})));
            parse(p,value,varargin{:});
            
            switch p.Results.type
                case 'f'
                    if value(1) < 0 || value(2) > obj.fs/2
                        disp(value);
                        error('f range too wide, should be between [0 fs/2]');
                    end
                    obj.f = value;
                    obj.w = obj.f/obj.fs;
                case 'w'
                    if value(1) < 0 || value(2) > 0.5
                        disp(value);
                        error('w range too wide, should be between [0 0.5]');
                    end
                    obj.w = value;
                    obj.f = obj.w*obj.fs;
                otherwise
                    error('unknown type %s',p.Results.type);
            end
            
        end 
        
        function value = get.freq_tag(obj)
            value = sprintf('-%0.4f-%0.4f',obj.w(1),obj.w(2)); 
        end
        
        function unload(obj)
            obj.pdc = [];
            obj.pdc_nfreqs = [];
            obj.pdc_loaded = '';
        end
        
        function load(obj,property,varargin)
            p = inputParser();
            addParameter(p,'file_idx',[],@(x) isnumeric(x) && (x > 0) && (x <= length(obj.file_pdc)));
            parse(p,varargin{:});
            
            if ~isempty(p.Results.file_idx)
                % only update if something was specified
                if obj.file_idx ~= p.Results.file_idx
                    % unload the data if it's changed
                    obj.unload();
                end
                obj.file_idx = p.Results.file_idx;
            end

            switch property
                case 'pdc'
                    if isempty(obj.pdc) || ~isequal(obj.pdc_loaded,'pdc')
                        print_msg_filename(obj.file_pdc{obj.file_idx},'loading');
                        data = loadfile(obj.file_pdc{obj.file_idx});
                        obj.pdc = data.pdc;
                        obj.pdc_nfreqs = data.nfreqs;
                        
                        dims = size(obj.pdc);
                        ndims = length(dims);
                        if ndims ~= 4
                            warning('pdc data is not dynamic');
                        end
                        obj.nchannels = size(obj.pdc,2);
                        obj.pdc_loaded = 'pdc';
                    end
                case 'pdc_sig'
                    if isempty(obj.pdc_sig)
                        if isempty(obj.file_pdc_sig)
                            error('missing file_pdc_sig');
                        end
                        print_msg_filename(obj.file_pdc_sig,'loading');
                        data = loadfile(obj.file_pdc_sig);
                        obj.pdc_sig = data.pdc;
                        
                        % pdc sig needs to be same size as pdc
                        dims = size(obj.pdc_sig);
                        if ~isequal(dims, size(obj.pdc))
                            obj.pdc_sig = [];
                            error('significant pdc is not the same size as pdc');
                        end
                    end
                    
                case 'pdc_mean'
                    if isempty(obj.pdc) || ~isequal(obj.pdc_loaded,'mean')
                        % compute/update mean
                        obj.mean();
                        
                        print_msg_filename(obj.file_pdc_mean,'loading');
                        data = loadfile(obj.file_pdc_mean);
                        obj.pdc = data.pdc_mean;
                        obj.pdc_nfreqs = data.nfreqs;
                        
                        dims = size(obj.pdc);
                        ndims = length(dims);
                        if ndims ~= 4
                            obj.pdc_mean = [];
                            error('requires dynamic pdc data');
                        end
                        obj.nchannels = size(obj.pdc,2);
                        obj.pdc_loaded = 'mean';
                    end
                case 'pdc_var'
                    if isempty(obj.pdc)  || ~isequal(obj.pdc_loaded,'var')
                        % compute/update var
                        obj.var();
                        
                        print_msg_filename(obj.file_pdc_var,'loading');
                        data = loadfile(obj.file_pdc_var);
                        obj.pdc = data.pdc_var;
                        obj.pdc_nfreqs = data.nfreqs;
                        
                        dims = size(obj.pdc);
                        ndims = length(dims);
                        if ndims ~= 4
                            obj.pdc_var = [];
                            error('requires dynamic pdc data');
                        end
                        obj.nchannels = size(obj.pdc,2);
                        obj.pdc_loaded = 'var';
                    end
                    
                case 'pdc_std'
                    if isempty(obj.pdc)  || ~isequal(obj.pdc_loaded,'std')
                        % compute/update std
                        obj.std();
                        
                        print_msg_filename(obj.file_pdc_std,'loading');
                        data = loadfile(obj.file_pdc_std);
                        obj.pdc = data.pdc_std;
                        obj.pdc_nfreqs = data.nfreqs;
                        
                        dims = size(obj.pdc);
                        ndims = length(dims);
                        if ndims ~= 4
                            obj.pdc_var = [];
                            error('requires dynamic pdc data');
                        end
                        obj.nchannels = size(obj.pdc,2);
                        obj.pdc_loaded = 'std';
                    end
 
                otherwise
                    error('unknown property %s',property);
            end
        end
        
        function [outdir, outfile] = get_fullsavefile(obj,varargin)
            %   Parameters
            %   ----------
            %   outdir (string, default = pwd)
            %       output directory
            %       by default uses output directory set in ViewPDC.outdir,
            %       can be overriden here with:
            %       1. 'data' - same directory where data is located
            %       2. any regular path
            
            p = inputParser();
            addParameter(p,'outdir','',@ischar);
            parse(p,varargin{:});
            
            outdir = obj.get_outdir(p.Results.outdir);
            outfile = obj.get_savefile();
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
        plot_directed(obj,varargin);
        plot_connectivity_matrix(obj,varargin);
        created = plot_seed(obj,chseed,varargin);
        
        % summary function
        out = get_summary(obj,varargin)
        print_summary(obj,varargin)
        
    end
    
    methods (Access = protected)
        function mean(obj)
            files_pdc = obj.file_pdc;
            nfiles = length(files_pdc);
            
            % create file name
            tag_mean = sprintf('-mean%d',nfiles);
            obj.file_pdc_mean = strrep(files_pdc{1},'.mat',[tag_mean '.mat']);
            
            % check freshness of mean file wrt all dependent pdc files
            fresh = false(nfiles,1);
            for i=1:nfiles
                fresh(i) = ViewPDC.isfresh(obj.file_pdc_mean,files_pdc{i});
            end
            
            data = [];
            if ~exist(obj.file_pdc_mean,'file') || any(fresh)
                data.pdc_mean = [];
                
                % sum all pdc files
                for i=1:nfiles
                    obj.load('pdc','file_idx',i);
                    data.nfreqs = obj.pdc_nfreqs;
                    if isempty(data.pdc_mean)
                        data.pdc_mean = obj.pdc;
                    else
                        data.pdc_mean = data.pdc_mean + obj.pdc;
                    end
                    obj.unload();
                end
                
                data.pdc_mean = data.pdc_mean/nfiles;
                save(obj.file_pdc_mean,'data','-v7.3');
            end
            
        end
        
        function std(obj)
            nfiles = length(obj.file_pdc);
            % create file name
            tag_std = sprintf('-std%d',nfiles);
            obj.file_pdc_std = strrep(obj.file_pdc{1},'.mat',[tag_std '.mat']);
            
            % check freshness of std file wrt all dependent pdc files
            fresh = false(nfiles,1);
            for i=1:nfiles
                fresh(i) = ViewPDC.isfresh(obj.file_pdc_std,obj.file_pdc{i});
            end
            
            if ~exist(obj.file_pdc_std,'file') || any(fresh)
                obj.var();
                
                % load var
                obj.load('pdc_var')
                
                data = [];
                % take sqrt of variance
                data.pdc_std = sqrt(obj.pdc);
                data.nfreqs = obj.pdc_nfreqs;
                save(obj.file_pdc_std,'data','-v7.3');
            end
        end
        
        function var(obj)
            files_pdc = obj.file_pdc;
            nfiles = length(files_pdc);
            
            % create file name
            tag_var = sprintf('-var%d',nfiles);
            obj.file_pdc_var = strrep(files_pdc{1},'.mat',[tag_var '.mat']);
            
            % check freshness of mean file wrt all dependent pdc files
            fresh = false(nfiles,1);
            for i=1:nfiles
                fresh(i) = ViewPDC.isfresh(obj.file_pdc_var,files_pdc{i});
            end
            
            if ~exist(obj.file_pdc_var,'file') || any(fresh)
                data = [];
                % compute mean
                obj.mean();
                
                % load mean
                obj.load('pdc_mean');
                pdc_mean = obj.pdc;
                
                data.pdc_var = [];
                for i=1:nfiles
                    % load each pdc file
                    obj.load('pdc','file_idx',i);
                    data.nfreqs = obj.pdc_nfreqs;
                    
                    % sum variance
                    if isempty(data.pdc_var)
                        data.pdc_var = (obj.pdc - pdc_mean).^2;
                    else
                        data.pdc_var = data.pdc_var + (obj.pdc - pdc_mean).^2;
                    end
                    obj.unload();
                end
                data.pdc_var = data.pdc_var/(nfiles-1);
                
                save(obj.file_pdc_var,'data','-v7.3');
            end
        end
        
        function fresh = check_pdc_freshness(obj,newfile)
            % checks PDC data file timestamp vs the newfile timestamp
            nfiles = length(obj.file_pdc);
            result = false(nfiles,1);
            for i=1:nfiles
                result(i) = ViewPDC.isfresh(newfile,obj.file_pdc{i});
            end
            fresh = any(result);
        end
        
        function outfile = get_savefile(obj)
            % returns the output file name
            if isempty(obj.save_tag)
                error('save tag not set in plot function');
            end
            
            switch obj.pdc_loaded
                case 'pdc'
                    tag_stat = '';
                otherwise
                    tag_stat = ['-' obj.pdc_loaded];
            end
            
            outfile = [obj.filename tag_stat obj.save_tag obj.freq_tag];
        end
        
        function outdir = get_outdir(obj,value)
            % returns the output directory
            
            if isempty(value)
                if isempty(obj.outdir)
                    if isequal(obj.outdir_type,'data')
                        outdir = obj.filepath;
                    else
                        outdir = pwd;
                        warning('no output directory specified\nusing default %s',outdir);
                    end
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
                labels = cell(obj.nchannels,1);
                for i=1:obj.nchannels
                    labels{i} = sprintf('%d',i);
                end
                obj.info = ChannelInfo(labels);
            end
        end
        
        function idx = sort_channels(obj,varargin)
            % sort by hemisphere, region, angle
            
            p = inputParser();
            addParameter(p,'type',{'coord','region','hemisphere'},@iscell);
            parse(p,varargin{:});
            
            flag_coord = false;
            flag_region = false;
            flag_hemi = false;
            for i=1:length(p.Results.type)
                switch p.Results.type{i}
                    case 'coord'
                        flag_coord = true;
                    case 'region'
                        flag_region = true;
                    case 'hemisphere'
                        flag_hemi = true;
                    otherwise
                        error('unknown type %s',p.Results.type{i});
                end
            end
            
            sort_method = [];
            group_data = [];
            
            if flag_coord && ~isempty(obj.info.coord)
                % sort coordinates according to angle around origin
                angles = atan2(obj.info.coord(:,2),obj.info.coord(:,1));
                
                sort_method = 1;
                group_data = angles(:);
            end
            
            if flag_region && ~isempty(obj.info.region_order)
                % add region order sort info
                group_data = [group_data obj.info.region_order(:)];
                ncol = size(group_data,2);
                sort_method = [ncol sort_method];
            end
            
            if flag_hemi && ~isempty(obj.info.hemisphere_order)
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
            
            if flag_hemi && ~isempty(obj.info.hemisphere)
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
    
    methods (Static)
        function fresh = isfresh(newfile,prevfile)
            % checks if prevfile is fresher than newfile
            fresh = false;
            if exist(newfile,'file')
                prev_time = get_timestamp(prevfile);
                new_time = get_timestamp(newfile);
                if prev_time > new_time
                    fresh = true;
                end
            end
        end
    end
    
end

