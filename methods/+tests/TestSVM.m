classdef TestSVM < matlab.unittest.TestCase
    
    properties
        x;
        y;
        x_train;
        x_test;
        y_train;
        y_test;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            load fisheriris
            classKeep = ~strcmp(species,'virginica');
            testCase.x = meas(classKeep,3:4);
            labels = species(classKeep);
            
            nsamples = size(testCase.x,1);
            ntest = 0.1*nsamples;
            ntrain = nsamples - ntest;
            
            class_names = unique(labels);
            testCase.y = zeros(size(labels));
            testCase.y = cellfun(@(x) isequal(x,class_names{1}),labels,'UniformOutput',true);
            testCase.y = double(testCase.y);
            
            testCase.x_train = testCase.x(1:ntrain,:);
            testCase.x_test = testCase.x(ntrain+1:end,:);
            testCase.y_train = testCase.y(1:ntrain);
            testCase.y_test = testCase.y(ntrain+1:end);
        end
        
    end
    
    methods (Test)
        function test_constructor(testCase)
            s = SVM(testCase.x_train, testCase.y_train,'implementation','libsvm');
            
            testCase.verifyEqual(s.samples,testCase.x_train);
            testCase.verifyEqual(s.class_labels,testCase.y_train);
            testCase.verifyEqual(s.implementation,'libsvm');
        end
        
        function test_train(testCase)
            s = SVM(testCase.x_train, testCase.y_train,'implementation','libsvm');
            s.train(...
                'KernelFunction','rbf',...
                'BoxConstraint',1,...
                'KernelScale',1);
            
            testCase.verifyNotEmpty(s.model);
            testCase.verifyTrue(isstruct(s.model));
        end
        
        function test_train_loss(testCase)
            s = SVM(testCase.x_train, testCase.y_train,'implementation','libsvm');
            [loss] = s.train(...
                'KernelFunction','rbf',...
                'BoxConstraint',1,...
                'KernelScale',1);
            
            testCase.verifyEmpty(s.model);
            testCase.verifyNotEmpty(loss);
        end
        
        function test_optimize(testCase)
            s = SVM(testCase.x_train, testCase.y_train,'implementation','libsvm');
            params = s.optimize(...
                'KernelFunction','rbf',...
                'box',[1,2],...
                'scale',[1,2]);
            
            testCase.verifyEmpty(s.model);
            testCase.verifyTrue(isfield(params,'KernelScale'));
            testCase.verifyTrue(isfield(params,'BoxConstraint'));
        end
        
        function test_predict(testCase)
            s = SVM(testCase.x_train, testCase.y_train,'implementation','libsvm');
            s.train(...
                'KernelFunction','rbf',...
                'BoxConstraint',1,...
                'KernelScale',1);
            
            prediction = s.predict(testCase.x_test);
            testCase.verifyEqual(length(prediction),length(testCase.y_test));
        end
    end
end