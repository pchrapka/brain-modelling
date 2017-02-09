classdef ViewPDC < handle
    %ViewPDC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        pdc;
        file;
        w;
        fs;
        labels;
        
        save_tag; % save tag for each plot type
        freq_tag; % freq tag for saving
        filepath;
        filename;
    end
    
    methods
        function obj = ViewPDC(file,varargin)
            
            p = inputParser();
            addRequired(p,'file',@ischar);
            addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2)); % not sure about this
            addParameter(p,'fs',1,@isnumeric);
            addParameter(p,'labels',{},@iscell);
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
            obj.labels = p.Results.labels;
            
            obj.freq_tag = sprintf('-%0.4f-%0.4f',obj.w(1),obj.w(2));
            obj.save_tag = [];
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
            p = inputParser();
            addParameter(p,'save',false,@islogical);
            addParameter(p,'outdir','',@ischar);
            parse(p,varargin{:});
            
            if isempty(p.Results.outdir)
                outdir = pwd;
                warning('no output directory specified\nusing default %s',outdir);
            elseif isequal(p.Results.outdir,'data');
                outdir = obj.filepath;
            else
                outdir = p.Results.outdir;
                if ~exist(outdir,'dir')
                    mkdir(outdir);
                end
            end
            
            if isempty(obj.save_tag)
                error('save tag not set in plot function');
            end
            
            if p.Results.save
                % save
                save_fig2(...
                    'path',outdir,...
                    'tag', [obj.filename obj.save_tag obj.freq_tag]);
                
                % clear save tag
                obj.save_tag = [];
            end
        end
        
        % plot functions
        plot_single(obj,chj,chi);
        plot_single_largest(obj,varargin);
        plot_single_multiple(obj,chj,chi,varargin)
        plot_summary(obj);
        plot_tiled(obj);
        
    end
    
    methods (Access = protected)
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

