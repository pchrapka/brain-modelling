classdef ViewLatticeFilter < handle
    properties
    end
    
    properties (SetAccess = protected)
        data;
        file;
    end
    
    methods
        
        function obj = ViewLatticeFilter(file,varargin)
            
            p = inputParser();
            addRequired(p,'file',@ischar);
            %addParameter(p,'outdir','data',@ischar);
            parse(p,file,varargin{:});
            
            
            obj.data = [];
            obj.file = file;
            %[obj.filepath,obj.filename,~] =  fileparts(obj.file);
            
            %obj.save_tag = [];
            %if isequal(p.Results.outdir,'data')
            %    obj.outdir = obj.filepath;
            %end
        end
        
        function load(obj)
            if isempty(obj.data)
                print_msg_filename(obj.file,'loading');
                obj.data = loadfile(obj.file);
            end
        end
        
        function unload(obj)
            obj.data = [];
        end
        
        % plot functions
        plot_esterror_vs_order(obj,varargin);
        plot_esterror_vs_order_vs_time(obj,varargin);
        plot_criteria_vs_order_vs_time(obj,varargin)
    end
    
    methods (Access = protected)
    end
end