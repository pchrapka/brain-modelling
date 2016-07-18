classdef Test_bricks_features_fdr < matlab.unittest.TestCase
    
    properties
        x;
        y;
        x_train;
        x_test;
        y_train;
        y_test;
        
        files_in;
        files_out;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            [srcdir,~,~] = fileparts(mfilename('fullpath'));
            testCase.files_in = fullfile(srcdir, 'sample-data.mat');
            testCase.files_out = fullfile(srcdir, 'sample-data-out.mat');
            
            load fisheriris
            classKeep = ~strcmp(species,'virginica');
            testCase.x = meas(classKeep,3:4);
            labels = species(classKeep);
            
            nsamples = size(testCase.x,1);
            ntest = ceil(0.1*nsamples);
            ntrain = nsamples - ntest;
            
            class_names = unique(labels);
            testCase.y = zeros(size(labels));
            testCase.y = cellfun(@(x) isequal(x,class_names{1}),labels,'UniformOutput',true);
            testCase.y = double(testCase.y);
            
            testCase.x_train = testCase.x(1:ntrain,:);
            testCase.x_test = testCase.x(ntrain+1:end,:);
            testCase.y_train = testCase.y(1:ntrain);
            testCase.y_test = testCase.y(ntrain+1:end);
            
            data = [];
            data.samples = [testCase.x_train zeros(ntrain,20)];
            data.class_labels = testCase.y_train;
            
            nfeatures = size(data.samples,2);
            for i=1:nfeatures
                data.feature_labels{i} = sprintf('f%d',i);
            end
            save(testCase.files_in,'data');
        end
        
    end
    
    methods (TestClassTeardown)
        function delete(testCase)
            if exist(testCase.files_in,'file')
                delete(testCase.files_in);
            end
            if exist(testCase.files_out,'file')
                delete(testCase.files_out);
            end
        end
    end
    
    methods (Test)
        function test_main(testCase)
            
            nfeatures = 2;
            bricks.features_fdr(testCase.files_in,testCase.files_out,{'nfeatures',nfeatures});
            
            testCase.verifyGreaterThan(exist(testCase.files_out,'file'),0);
            
            nsamples = length(testCase.y_train);
            
            data = loadfile(testCase.files_out);
            testCase.verifyEqual(length(data.feature_labels), nfeatures);
            testCase.verifyEqual(size(data.feat_sel_fdr,1), nfeatures);
            testCase.verifyEqual(size(data.features), [nsamples nfeatures]);
            testCase.verifyEqual(length(data.class_labels), nsamples);
        end
        
    end
end