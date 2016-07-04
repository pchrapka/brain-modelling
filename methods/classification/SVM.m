classdef SVM < handle
    %SVM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        samples;
        class_labels;
        model;
        implementation;
    end
    
    methods
        function obj = SVM(samples, class_labels,varargin)
            %SVM constructs an SVM object
            %   obj = SVM(samples, class_labels) constructs an SVM object
            %   
            %   Input
            %   -----
            %   samples (matrix)
            %       samples for classifier, matrix has dimensions [sample
            %       feature], i.e. each row represents a new sample and
            %       each column represents one feature
            %   class_labels (vector)
            %       class label for each sample
            %
            %   Parameters
            %   ----------
            %   implementation (string, default = libsvm)
            %       specify the svm implementation: matlab or libsvm
            %
            %   Output
            %   ------
            %   obj
            %       SVM object
            
            p = inputParser();
            addRequired(p,'samples',@ismatrix);
            addRequired(p,'class_labels',@isvector);
            options_imp = {'matlab','libsvm'};
            addParameter(p,'implementation','libsvm',@(x) any(validatestring(x,options_imp)));
            parse(p,samples,class_labels,varargin{:});
            
            obj.samples = p.Results.samples;
            obj.class_labels = p.Results.class_labels;
            obj.implementation = p.Results.implementation;
        end
        
        function params = optimize(obj, varargin)
            %OPTIMIZE optimizes SVM parameters KernelScale and BoxConstraint
            %   OPTIMIZE(...) optimizes SVM parameters KernelScale and
            %   BoxConstraint
            %
            %   Parameters
            %   ----------
            %   box (vector)
            %       BoxConstraint parameter choices, default = exp(-2:2)
            %   scale (vector)
            %       KernelScale parameter choices, default = exp(-2:2)
            %   verbosity (integer, default = 0)
            %       verbosity level of function, choices 0,1,2,3
            %
            %   matlab implementation
            %   parameters are passed on to fitcsvm, see fitcsvm
            %
            %   libsvm implementation
            %   KernelFunction (string, default = 'rbf')
            %
            %   Output
            %   ------
            %   params.KernelScale
            %       optimal value of KernelScale
            %   params.BoxConstraint
            %       optimal value of BoxConstraint
            
            p = inputParser;
            p.KeepUnmatched = true;
            params_box = exp(-2:2);
            addParameter(p,'box',params_box);
            params_scale = exp(-2:2);
            addParameter(p,'scale',params_scale);
            params_verbosity = [0 1 2 3];
            addParameter(p,'verbosity',0,@(x) any(find(params_verbosity == x)));
            parse(p,varargin{:});
            
            if p.Results.verbosity > 0
                fprintf('Optimizing over grid\n');
            end

            % allocate mem for loss
            loss = zeros(length(p.Results.box), length(p.Results.scale));
            implementation_cpy = obj.implementation;
                        
            % loop over parameter choices
            for i=1:length(p.Results.box)
                parfor j=1:length(p.Results.scale)
                %for j=1:length(p.Results.scale)
                    
                    % Train the SVM
                    if isequal(implementation_cpy,'matlab')
                        svm_params = struct2namevalue(p.Unmatched);
                        svm_params = [svm_params...
                            'BoxConstraint', p.Results.box(i),...
                            'KernelScale', p.Results.scale(j),...
                            ];
                        
                        [~,loss(i,j)] = svmtrain_static(...
                            obj.samples, obj.class_labels, svm_params{:});
                    else
                        svm_params = [fieldnames(p.Unmatched) struct2cell(p.Unmatched)];
                        svm_params = reshape(svm_params',1,numel(svm_params));
                        svm_params = [svm_params...
                            'BoxConstraint', p.Results.box(i),...
                            'KernelScale', p.Results.scale(j),...
                            'verbosity', p.Results.verbosity,...
                            ];
                        
                        [~,loss(i,j)] = svmtrain_static(...
                            obj.samples, obj.class_labels, svm_params{:});
                    end
                    
                    if p.Results.verbosity > 2
                        fprintf('\tLoss: %0.6f\n', loss(i,j));
                    end
                    
                end
            end
            
            % Choose the params with the lowest CV loss
            if p.Results.verbosity > 1
                fprintf('Loss:\n');
                disp(loss);
            end
            [~,idx] = min(loss(:));
            [i,j] = ind2sub(size(loss), idx);
            params.BoxConstraint = p.Results.box(i);
            params.KernelScale = p.Results.scale(j);
            if p.Results.verbosity > 0
                fprintf('Optimal params:\n');
                fprintf('\tBoxConstraint exp(%.4f)\n\tKernelScale exp(%.4f)\n',...
                    log(params.BoxConstraint), log(params.KernelScale));
            end
        end
        
        function [varargout] = train(obj, varargin)
            %TRAIN trains an SVM model
            %   TRAIN(...) trains an SVM model
            %
            %   loss = TRAIN(...) returns loss associated with the SVM
            %   model
            %
            %   Parameters
            %   ----------
            %   matlab implementation
            %   see fitcsvm
            %
            %   libsvm implementation
            %   KernelFunction (string, default = 'rbf')
            %   BoxConstraint (scalar, default = 0)
            %   KernelScale (scalar, default = 1);
            %
            %   Output
            %   ------
            %   loss (scalar)
            %       loss associated with the SVM
            
            varargin = [varargin 'implementation' obj.implementation];
            if nargout > 0
                [obj.model,loss] = svmtrain_static(...
                    obj.samples, obj.class_labels, varargin{:});
                varargout{1} = loss;
            else
                [obj.model] = svmtrain_static(obj.samples, obj.class_labels, varargin{:});
            end
            
            
        end
        
        function prediction = predict(obj, test)
            %PREDICT predicts class of a test sample
            %   PREDICT(...) predicts class of a test sample
            %
            %   Input
            %   -----
            %   test (matrix)
            %       test sample, size [samples features]
            %
            %   Output
            %   ------
            %   prediction (vector)
            %       predicted class label for test sample
            
            if isequal(obj.implementation,'matlab')
                prediction = predict(obj.model, test);
            else
                test_labels = zeros(size(test,1),1);
                prediction = svmpredict(test_labels, test, obj.model, '-q');
            end
        end
    end
    
    methods (Static, Access = protected)
        
        
    end
    
end


