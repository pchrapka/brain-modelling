classdef SVM < handle
    %SVM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        samples;
        class_labels;
        model;
    end
    
    methods
        function obj = SVM(samples, class_labels)
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
            %   Output
            %   ------
            %   obj
            %       SVM object
            
            obj.samples = samples;
            obj.class_labels = class_labels;
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
            %       verbosity level of function, choices 0,1,2
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
            params_verbosity = [0 1 2];
            addParameter(p,'verbosity',0,@(x) any(find(params_verbosity == x)));
            parse(p,varargin{:});
            
            if p.Results.verbosity > 0
                fprintf('Optimizing over grid\n');
            end

            % allocate mem for loss
            loss = zeros(length(p.Results.box), length(p.Results.scale));
            
            % loop over parameter choices
            for i=1:length(p.Results.box)
                for j=1:length(p.Results.scale)
                    
                    % Train the SVM
                    svm_params = [fieldnames(p.Unmatched) struct2cell(p.Unmatched)];
                    svm_params = reshape(svm_params',1,numel(svm_params));
                    model = fitcsvm(obj.samples, obj.class_labels,...
                        'BoxConstraint', p.Results.box(i),...
                        'KernelScale', p.Results.scale(j),...
                        svm_params{:});
                    
                    % Calculate the loss or CV error
                    loss(i,j) = kfoldLoss(model); % TODO double check output
                    if p.Results.verbosity > 1
                        fprintf('\tLoss: %0.6f\n', loss(i,j));
                    end
                    
                end
            end
            
            % Choose the params with the lowest CV loss
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
        
        function obj = train(obj, varargin)
            %TRAIN trains an SVM model
            %   TRAIN(...) trains an SVM model
            %
            %   Parameters
            %   ----------
            %   see fitcsvm
            %
            %   Output
            %   ------
            %   updates obj.model
            
            obj.model = fitcsvm(obj.samples, obj.class_labels, varargin{:});
        end
        
        function prediction = predict(obj, test)
            %PREDICT predicts class of a test sample
            %   PREDICT(...) predicts class of a test sample
            %
            %   Input
            %   -----
            %   test (vector)
            %       test sample
            %
            %   Output
            %   ------
            %   prediction
            %       predicted class label for test sample
            
            
            prediction = predict(obj.model, test);
        end
    end
    
end

