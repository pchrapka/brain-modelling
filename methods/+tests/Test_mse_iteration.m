classdef Test_mse_iteration < matlab.unittest.TestCase
    %Test_mse_iteration Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        estimate;
        truth;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            t = 0:10;
            t = t(:);
            testCase.estimate{1} = [exp(-0.4*t) exp(-0.5*t)];
            testCase.truth{1} = [(-0.3/10*t + 0.3) (-0.3/10*t + 0.3)];
            
            testCase.estimate{2} = [exp(-0.2*t) exp(-0.25*t)];
            testCase.truth{2} = [(-0.3/10*t + 0.3) (-0.3/10*t + 0.3)];
        end
    end
    
    methods (Test)
        function test_iter1(testCase)
            data_mse = mse_iteration(testCase.estimate{1}, testCase.truth{1});
            
            nsims = 1;
            niter = 11;
            testCase.verifyEqual(size(data_mse), [niter, nsims]);
        end
        
        function test_iter2(testCase)
            data_mse = mse_iteration(testCase.estimate, testCase.truth);
            
            nsims = 2;
            niter = 11;
            testCase.verifyEqual(size(data_mse), [niter, nsims]);
        end
        
    end
    
end

