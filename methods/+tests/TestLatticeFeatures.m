classdef TestLatticeFeatures < matlab.unittest.TestCase
    %TestLatticeFeatures Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dims;
        data;
    end
    
    properties (TestParameter)
        feat_name = {'hist','mean','std','var',...
            'harmmean','trimmean','kurtosis','skewness'};
        feat_size = struct('hist',10,'mean',1,'std',1,'var',1,...
            'harmmean',1,'trimmean',1,'kurtosis',1,'skewness',1);
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            nsamples = 4;
            norder = 3;
            nchannels = 5;
            testCase.dims = [nsamples, norder, nchannels, nchannels];
            testCase.data = randn(testCase.dims);
        end
    end
    
    methods (TestClassTeardown)
    end
    
    methods (Test)
        function test_LatticeFeatures(testCase)
            % test constructor
            lf = LatticeFeatures(testCase.data);
            testCase.verifyFalse(isempty(lf.data));
        end
        
        function test_LatticeFeatures_error(testCase)
            % test incorrect data size
            temp = randn(3,2,1);
            testCase.verifyError(@() LatticeFeatures(temp),'LatticeFeatures:LatticeFeatures');
        end
        
        function test_add_all(testCase)
            % test add all features
            lf = LatticeFeatures(testCase.data);
            for i=1:length(testCase.feat_name)
                name = testCase.feat_name{i};
                lf.add(name);
                testCase.verifyEqual(lf.features_added{end},name);
            end
            testCase.verifyEqual(length(lf.features_added), length(testCase.feat_name));
        end
        
        function test_add_error(testCase)
            % test add error, adding same feature twice
            lf = LatticeFeatures(testCase.data);
            lf.add(testCase.feat_name{1});
            testCase.verifyError(@() lf.add(testCase.feat_name{1}) ,'LatticeFeatures:add');
        end
        
        function test_add_error_fake(testCase)
            % test add error, try adding missing feature method
            lf = LatticeFeatures(testCase.data);
            testCase.verifyError(@() lf.add('aaa'),'MATLAB:noSuchMethodOrField');
        end
    end
    
    methods (Test, ParameterCombination='sequential')
        function test_add(testCase,feat_name,feat_size)
            % test all features and output sizes
            lf = LatticeFeatures(testCase.data);
            lf.add(feat_name);
            
            n = prod(testCase.dims(2:end))*feat_size;
            testCase.verifyEqual(size(lf.features),[n 1]);
            testCase.verifyEqual(size(lf.labels),[n 1]);
            testCase.verifyEqual(lf.features_added{1},feat_name);
            
        end
    end
    
end

