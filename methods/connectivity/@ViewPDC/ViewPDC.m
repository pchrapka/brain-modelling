classdef ViewPDC < handle
    %ViewPDC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        w;
    end
    
    properties (SetAccess = protected)
        pdc;
        file;
        fs;
        labels;
        time;
        coords;
        
        save_tag; % save tag for each plot type
        freq_tag; % freq tag for saving
        filepath;
        filename;
        outdir;
    end
    
    methods
        function obj = ViewPDC(file,varargin)
            
            p = inputParser();
            addRequired(p,'file',@ischar);
            addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2));
            addParameter(p,'fs',1,@isnumeric);
            addParameter(p,'labels',{},@iscell);
            addParameter(p,'coords',[],@isnumeric);
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
            
            % check labels and coords
            if ~isempty(p.Results.coords)
                dims_coords = size(p.Results.coords);
                if length(dims_coords) < 2 || length(dims_coords) > 3
                    disp(dims_coords);
                    error('invalid dimensions for coords, either 2d or 3d');
                end
                nlabels = length(p.Results.labels);
                if nlabels ~= dims_coords(1)
                    error('not enough coords (%d) for labels (%d)',dims_coords(1),nlabels);
                end
            end
            
            obj.labels = p.Results.labels;
            obj.coords = p.Results.coords;
            
            obj.freq_tag = sprintf('-%0.4f-%0.4f',obj.w(1),obj.w(2));
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
        
        function unload(obj)
            obj.pdc = [];
        end
        
        function load(obj)
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
            parse(p,varargin{:});
            
            if p.Results.save
                outdir = obj.get_outdir(p.Results.outdir);
                outfile = obj.get_savefile();
                
                % save
                save_fig2('path',outdir,'tag', outfile);
                
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
        plot_seed(obj,chseed,varargin)
        
        % summary function
        out = get_summary(obj,varargin)
        print_summary(obj,varargin)
        
    end
    
    methods (Access = protected)        
        function fresh = check_pdc_freshness(obj,newfile)
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
            if isempty(obj.save_tag)
                error('save tag not set in plot function');
            end
            
            outfile = [obj.filename obj.save_tag obj.freq_tag];
        end
        
        function outdir = get_outdir(obj,value)
            
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
        
        function add_time_ticks(obj,axis)
            if isempty(obj.time)
                fprintf('time is empty\n');
                return;
            end
            
            % fnid zero index
            temp = obj.time >= 0;
            zero_idx = find(temp,1,'first');
            if isempty(zero_idx)
                zero_idx = 1;
            end
            ticks = zero_idx;
            
            nticks = 5;
            npointspertick = floor(length(obj.time)/nticks);
            extra_idx = -nticks:1:nticks;
            extra_idx = extra_idx*npointspertick + zero_idx;
            extra_idx = extra_idx(extra_idx > 0 & extra_idx < length(obj.time));
            
            ticks = [ticks extra_idx];
            ticks = sort(unique(ticks));
            ticklabels = obj.time(ticks);
            
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
        
        function hxlabel = labelitx(obj,j) % Labels x-axis plottings
            if isempty(obj.labels)
                hxlabel = xlabel(['j = ' int2str(j)]);
                set(hxlabel,'FontSize',12, ... %'FontWeight','bold', ...
                    'FontName','Arial') % 'FontName','Arial'
            else
                hxlabel = xlabel(obj.labels{j});
                set(hxlabel,'FontSize',12) %'FontWeight','bold')
            end
        end
        
        function [hylabel] = labelity(obj,i) % Labels y-axis plottings
            if isempty(obj.labels)
                hylabel = ylabel(['i = ' int2str(i)],...
                    'Rotation',90);
                set(hylabel,'FontSize',12, ... %'FontWeight','bold', ...
                    'FontName','Arial')  % 'FontName','Arial', 'Times'
            else
                hylabel = ylabel(obj.labels{i});
                set(hylabel,'FontSize',12); %'FontWeight','bold','Color',[0 0 0])
            end
            
        end
    end
end

