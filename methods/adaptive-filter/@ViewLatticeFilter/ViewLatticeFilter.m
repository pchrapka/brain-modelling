classdef ViewLatticeFilter < handle
    properties
    end
    
    properties (SetAccess = protected)
        criteria;
        criteriaidx;
        criteriafiles;
        data;
        dataidx;
        datafiles;
        datafile_labels;
    end
    
    methods
        
        function obj = ViewLatticeFilter(files,varargin)
            
            p = inputParser();
            addRequired(p,'files',@(x) iscell(x) || ischar(x));
            addParameter(p,'labels',{},@(x) iscell(x) || ischar(x));
            %addParameter(p,'outdir','data',@ischar);
            parse(p,files,varargin{:});
            
            if ischar(files)
                files = {files};
            end
            
            if ischar(p.Results.labels)
                labels = {p.Results.labels};
            else
                labels = p.Results.labels;
            end
            
            obj.data = [];
            obj.dataidx = 0;
            obj.datafiles = files;
            if isempty(labels)
                % create generic labels
                for i=1:length(files)
                    labels{i} = sprintf('file %d',i);
                end
            end
            if length(labels) ~= length(files)
                error('files and labels do not match');
            end
            obj.datafile_labels = labels;
            
            obj.criteria = [];
            obj.criteriaidx = 0;
            obj.criteriafiles = {};
            %[obj.filepath,obj.filename,~] =  fileparts(obj.file);
            
            %obj.save_tag = [];
            %if isequal(p.Results.outdir,'data')
            %    obj.outdir = obj.filepath;
            %end
        end
        
        function init_criteria(obj)
            for i=1:length(obj.datafiles)
                % create new criteria file based on data file name
                [filepath,filename,~] = fileparts(obj.datafiles{i});
                filename_new = [filename '-info-criteria.mat'];
                obj.criteriafiles{i} = fullfile(filepath,filename_new);
            end
        end
        
        function load(obj,field,idx)
            switch field
                case 'data'
                    if exist(obj.datafiles{idx},'file')
                        if isempty(obj.data) || obj.dataidx ~= idx
                            print_msg_filename(obj.datafiles{idx},'loading');
                            obj.data = loadfile(obj.datafiles{idx});
                            obj.dataidx = idx;
                        end
                    else
                        obj.data = [];
                        obj.dataidx = 0;
                    end
                case 'criteria'
                    if exist(obj.criteriafiles{idx},'file')
                        if isempty(obj.criteria) || obj.criteriaidx ~= idx
                            print_msg_filename(obj.criteriafiles{idx},'loading');
                            obj.criteria = loadfile(obj.criteriafiles{idx});
                            obj.criteriaidx = idx;
                        end
                    else
                        obj.data = [];
                        obj.dataidx = 0;
                    end
            end
            
        end
        
        function unload(obj,field)
            switch field
                case 'data'
                    obj.data = [];
                    obj.dataidx = 0;
                case 'criteria'
                    obj.criteria = [];
                    obj.criteriaidx = 0;
            end
        end
        
        % measure functions
        compute(obj,criteria);
        out = get_criteria(obj,varargin);
        
        % plot functions
        plot_criteria_vs_order(obj,varargin);
        plot_criteria_vs_order_vs_time(obj,varargin)
    end
    
    methods (Access = protected)
        [cf,cb] = compute_criteria(obj,criteria,order)
        
        function fresh = check_data_freshness(obj,idx)
            % checks data file timestamp vs the newfile timestamp
            fresh = false;
            if exist(obj.criteriafiles{idx},'file')
                data_time = get_timestamp(obj.datafiles{idx});
                new_time = get_timestamp(obj.criteriafiles{idx});
                if data_time > new_time
                    fresh = true;
                end
            end
        end
        
        function [ferror,berror] = get_error(obj,order_idx,sample_idx)
            if nargin < 2
                sample_idx = [];
            end
            
            dims = size(obj.data.estimate.ferror);
            
            if isempty(sample_idx)
                switch length(dims)
                    case 4
                        ferror = obj.data.estimate.ferror(:,:,:,order_idx);
                        berror = obj.data.estimate.berrord(:,:,:,order_idx);
                    case 3
                        ferror = obj.data.estimate.ferror(:,:,order_idx);
                        berror = obj.data.estimate.berrord(:,:,order_idx);
                    otherwise
                        error('uh oh\n');
                end
            else
                switch length(dims)
                    case 4
                        ferror = obj.data.estimate.ferror(sample_idx,:,:,order_idx);
                        berror = obj.data.estimate.berrord(sample_idx,:,:,order_idx);
                    case 3
                        ferror = obj.data.estimate.ferror(sample_idx,:,order_idx);
                        berror = obj.data.estimate.berrord(sample_idx,:,order_idx);
                    otherwise
                        error('uh oh\n');
                end
            end
            
            ferror = squeeze(ferror);
            berror = squeeze(berror);
        end
    end
end