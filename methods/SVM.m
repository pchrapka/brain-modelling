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
            
            % loop over parameter choices
            for i=1:length(p.Results.box)
                for j=1:length(p.Results.scale)
                    
                    % Train the SVM
                    if isequal(obj.implementation,'matlab')
                        svm_params = [fieldnames(p.Unmatched) struct2cell(p.Unmatched)];
                        svm_params = reshape(svm_params',1,numel(svm_params));
                        model = fitcsvm(obj.samples, obj.class_labels,...
                            'BoxConstraint', p.Results.box(i),...
                            'KernelScale', p.Results.scale(j),...
                            svm_params{:});
                        
                        % Calculate the loss or CV error
                        loss(i,j) = kfoldLoss(model); % TODO double check output
                    else
                        % set svm options
                        % svm type
                        svm_type = '-s 0 ';
                        % kernel type
                        switch p.Unmatched.KernelFunction
                            case 'rbf'
                                kernel = '-t 2 ';
                        end
                        % kernel scale
                        gamma = sprintf('-g %g ', p.Results.scale(j));
                        % cost constraint
                        cost = sprintf('-c %g ', p.Results.box(i));
                        % n-fold cross validation mode
                        crossval = sprintf('-v %d ', length(obj.class_labels));
                        
                        if p.Results.verbosity > 2
                            options = [svm_type kernel gamma cost crossval];
                        else
                            % quiet mode
                            options = [svm_type kernel gamma cost crossval '-q'];
                        end
                    
                        accuracy = svmtrain(obj.class_labels, obj.samples, options);
                        loss(i,j) = 100 - accuracy;
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
            
            if isequal(obj.implementation,'matlab')
                obj.model = fitcsvm(obj.samples, obj.class_labels, varargin{:});
            else
                p = inputParser();
                addParameter(p,'KernelFunction','rbf');
                addParameter(p,'BoxConstraint',0,@isnumeric);
                addParameter(p,'KernelScale',1,@isnumeric);
                parse(p,varargin{:});
                
                % set svm options
                % svm type
                svm_type = '-s 0 ';
                % kernel type
                switch p.Results.KernelFunction
                    case 'rbf'
                        kernel = '-t 2 ';
                end
                % kernel scale
                gamma = sprintf('-g %g ', p.Results.KernelScale);
                % cost constraint
                cost = sprintf('-c %g ', p.Results.BoxConstraint);
                
                options = [svm_type kernel gamma cost '-q'];
                
                obj.model = svmtrain(obj.class_labels, obj.samples, options);
            end
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
            
            if isequal(obj.implementation,'matlab')
                prediction = predict(obj.model, test);
            else
                prediction = svmpredict(1, test, obj.model, '-q');
            end
        end
    end
    
end


