classdef SVMMRMR < handle
    %SVMMRMR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        samples;
        class_labels;
        feature_labels;
    end
    
    methods
        function obj = SVMMRMR(samples, class_labels, varargin)
            %SVMMRMR constructor for SVMMRMR
            %   SVMMRMR(samples, class_labels, [feature_labels])
            %
            %   Input
            %   -----
            %   samples (matrix)
            %       samples for classifier, matrix has dimensions [sample
            %       feature], i.e. each row represents a new sample and
            %       each column represents one feature
            %   class_labels (vector)
            %       class label for each sample
            %   feature_labels (optional, cell array)
            %       label for each feature
            %
            %   Output
            %   ------
            %   obj (SVMMRMR object)
            %       SVMMRMR object
            
            p = inputParser;
            addRequired(p,'samples',@ismatrix);
            addRequired(p,'class_labels',@isvector);
            addParameter(p,'feature_labels',{},@iscell);
            parse(p,samples, class_labels, varargin{:});
            
            obj.samples = p.Results.samples;
            obj.class_labels = p.Results.class_labels;
            obj.feature_labels = p.Results.feature_labels;
        end
        
        function [predictions, feat_sel] = validate_features(obj,varargin)
            %VALIDATE_FEATURES validates feature selection
            %   VALIDATE_FEATURES(...) validates feature selection
            %
            %   Outline of algorithm:
            %   
            %   parfor each sample
            %       leave one out
            %       select N features using MRMR
            %       optimize SVM using a grid search and leave one out
            %       train an SVM with optimal params
            %       predict
            %
            %   NOTES:
            %   parfor setup
            %       make sure to configure your machine for parallel
            %       execution
            %
            %   Input
            %   -----
            %
            %   Parameters
            %   ----------
            %   nfeatures (integer, default = 10)
            %       number of features to select during mRMR step
            %   nbins (integer, default = 10)
            %       number of bins to use for the discretization
            %
            %       NOTE for feature selection 10 bins is a good choice
            %       (Brown2012, "Conditional Likelihood Maximisation: A
            %       Unifying Framework for Information Theoretic Feature
            %       Selection")
            %
            %   verbosity (integer, default = 0)
            %       verbosity level of function, choices 0,1,2
            %
            %   Output
            %   ------
            %   predictions (vector)
            %       predicted labels of each left out sample
            %   feat_sel (matrix)
            %       matrix of selected feature indices with the following format
            %       [features runs], i.e. each column represents the features selected
            %       in one iteration of a leave one out loop
            
            p = inputParser;
            addParameter(p,'nfeatures',10,@isnumeric);
            addParameter(p,'nbins',10,@isnumeric);
            params_verbosity = [0 1 2];
            addParameter(p,'verbosity',0,@(x) any(find(params_verbosity == x)));
            parse(p,varargin{:});
            
            % discretize features
            samples_discrete = discretize_reflection_coefs(...
                obj.samples, 'bins', p.Results.nbins,...
                'min', -1.5, 'max', 1.5);
            
            nsamples = size(obj.samples,1);
            
            % allocate mem
            feat_sel = zeros(p.Results.nfeatures, nsamples);
            predictions = zeros(nsamples,1);
            
            nfeatures = p.Results.nfeatures;
            verbosity = p.Results.verbosity;
            
            % loop over samples
            parfor i=1:nsamples
                % Set up leave one out
                testidx = zeros(nsamples,1);
                testidx(i) = 1;
                
                % mRMR - select features
                %%%%%
                
                [feat_sel(:,i)] = feast('mrmr',...
                    nfeatures,...
                    samples_discrete(~testidx,:),...
                    obj.class_labels(~testidx));
                
                if verbosity > 1 
                    fprintf('Features selected:\n');
                    if ~isempty(obj.feature_labels)
                        fprintf('\t%s\n',obj.feature_labels{feat_sel(:,i)});
                    else
                        fprintf('\t%d\n',feat_sel(:,i));
                    end
                end
                
                
                % Optimize SVM for currently selected features
                %%%%%
                
                % Partition samples into a leave one out scheme
                c = cvpartition(nsamples-1, 'KFold', nsamples-1);
            
                svm_model = SVM(...
                    obj.samples(~testidx,feat_sel(:,i)),...
                    obj.class_labels(~testidx));
                params = svm_model.optimize(...
                    'Standardize', true,...
                    'CVPartition', c,...
                    ...'Leaveout', 'on',...
                    'KernelFunction','rbf',...
                    'verbosity', verbosity);
                
                % Train SVM with optimized params
                %%%%%
                
                svm_model.train(...
                    'Standardize', true,...
                    'KernelFunction','rbf',...
                    'BoxConstraint',params.BoxConstraint,...
                    'KernelScale',params.KernelScale);
                
                % Predict
                %%%%%
                
                % Test the sample that was left out
                predictions(i) = svm_model.predict(obj.samples(i,feat_sel(:,i)));
            end
            
        end
    end
    
end

