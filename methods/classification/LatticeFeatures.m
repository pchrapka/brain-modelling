classdef LatticeFeatures < handle
    %LatticeFeatures Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties(SetAccess = private)
        features_added = {};
        features = [];          % column vector
        data = [];              % data matrix
        labels = {};
        temp;
    end
    
    methods
        function obj = LatticeFeatures(data)
            %   data (matrix)
            %       reflection coefficient matrix, [samples order channels channels]
            
            if length(size(data)) ~= 4
                error([mfilename ':LatticeFeatures'],...
                    'bad data size: %d expecting 4\n',length(size(data)));
            end
            
            obj.data = data;
        end
        
        function obj = add(obj, feature_name, varargin)
            %   feature_name (string)
            %       name of feature
            
            if ~isempty(obj.features_added)
                % check if the feature has already been added
                expr = feature_name;
                list = obj.features_added;
                cell_matches = cellfun(@(x) regexp(x, expr, 'match'), list, 'UniformOutput',false);
                if ~isempty([cell_matches{:}])
                    error([mfilename ':add'],...
                        'feature already added %s',feature_name);
                end
            end
            
            % compute the feature and add
            obj.compute_feature(feature_name,varargin{:});

        end
    end
    
    methods(Access = protected)
        function obj = add_feature_data(obj,data,labels)
            %   data (vector)
            %       vector of features
            %   labels (cell array)
            %       cell array of feature labels
            
            % concatenate the features
            data = reshape(data,numel(data),1);
            obj.features = [obj.features; data];
            
            % concatenate the labels
            if iscell(labels)
                labels = reshape(labels,numel(labels),1);
            end
            obj.labels = [obj.labels; labels];
        end
        
        function obj = add_feature_name(obj,name)
            %   name (string)
            %       feature name
            
            % concatenate the feature name
            obj.features_added = [obj.features_added name];
        end
        
        function obj = compute_feature(obj,feature_name,varargin)
            %   feature_name (string)
            %       feature name
            %   varargin
            %       options for feature function
            
            % get data size
            [~,norder,nchannels,~] = size(obj.data);
            
            % loop over dims
            for i=1:norder
                for j=1:nchannels
                    for k=1:nchannels
                        % dynamically construct function handle for feature method 
                        eval(sprintf('func_feat = @obj.%s;',feature_name));
                        
                        % compute specific feature
                        dims = [i j k];
                        [feat,feat_labels] = func_feat(dims, varargin{:});
                        
                        % add feature data
                        obj.add_feature_data(feat,feat_labels);
                    end
                end
            end
            
            obj.add_feature_name(feature_name);
            
            % clear temporary feature data
            if isfield(obj.temp, feature_name)
                obj.temp = rmfield(obj.temp, feature_name);
            end
        end
        
        % standardized feature methods for all samples
        function [feat,feat_labels] = hist(obj,dims,varargin)
            % compute histogram
            [feat,idx] = hist(obj.data(:,dims(1),dims(2),dims(3)),varargin{:});
            
            % make labels
            feat_labels = cell(length(idx),1);
            for m=1:length(idx)
                feat_labels{m} = sprintf('hist-p%dc%dc%dv%f',...
                    dims(1),dims(2),dims(3),idx(m));
            end
        end
        
        function [feat,feat_labels] = var(obj,dims,varargin)
            if ~isfield(obj.temp,'var')
                % compute var on all data
                obj.temp.var = var(obj.data);
            end
            % get data
            feat = squeeze(obj.temp.var(:,dims(1),dims(2),dims(3)));
            feat_labels = sprintf('var-p%dc%dc%d',dims(1),dims(2),dims(3));
        end
        function [feat,feat_labels] = std(obj,dims,varargin)
            if ~isfield(obj.temp,'std')
                % compute on all data
                obj.temp.std = std(obj.data);
            end
            % get data
            feat = squeeze(obj.temp.std(:,dims(1),dims(2),dims(3)));
            feat_labels = sprintf('std-p%dc%dc%d',dims(1),dims(2),dims(3));
        end
        function [feat,feat_labels] = mean(obj,dims,varargin)
            if ~isfield(obj.temp,'mean')
                % compute on all data
                obj.temp.mean = std(obj.data);
            end
            % get data
            feat = squeeze(obj.temp.mean(:,dims(1),dims(2),dims(3)));
            feat_labels = sprintf('mean-p%dc%dc%d',dims(1),dims(2),dims(3));
        end
        function [feat,feat_labels] = harmmean(obj,dims,varargin)
            if ~isfield(obj.temp,'harmmean')
                % compute on all data
                obj.temp.harmmean = std(obj.data);
            end
            % get data
            feat = squeeze(obj.temp.harmmean(:,dims(1),dims(2),dims(3)));
            feat_labels = sprintf('harmmean-p%dc%dc%d',dims(1),dims(2),dims(3));
        end
        function [feat,feat_labels] = trimmean(obj,dims,varargin)
            if isempty(varargin)
                % set defaults
                varargin{1} = 5;
            end
            if ~isfield(obj.temp,'trimmean')
                % compute on all data
                obj.temp.trimmean = std(obj.data);
            end
            % get data
            feat = squeeze(obj.temp.trimmean(:,dims(1),dims(2),dims(3)));
            feat_labels = sprintf('trimmean-p%dc%dc%d',dims(1),dims(2),dims(3));
        end
        function [feat,feat_labels] = kurtosis(obj,dims,varargin)
            if ~isfield(obj.temp,'kurtosis')
                % compute on all data
                obj.temp.kurtosis = std(obj.data);
            end
            % get data
            feat = squeeze(obj.temp.kurtosis(:,dims(1),dims(2),dims(3)));
            feat_labels = sprintf('kurtosis-p%dc%dc%d',dims(1),dims(2),dims(3));
        end
        function [feat,feat_labels] = skewness(obj,dims,varargin)
            if ~isfield(obj.temp,'skewness')
                % compute on all data
                obj.temp.skewness = std(obj.data);
            end
            % get data
            feat = squeeze(obj.temp.skewness(:,dims(1),dims(2),dims(3)));
            feat_labels = sprintf('skewness-p%dc%dc%d',dims(1),dims(2),dims(3));
        end
    end    
end

