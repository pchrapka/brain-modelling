classdef TestAnalysisBeamformer < matlab.unittest.TestCase
    
    properties
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_test(testCase)
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.out_folder = fullfile(testdir,'output');
        end
    end
    
    methods (TestClassTeardown) 
    end
    
    methods (Test)
        function test_constructor(testCase)
           a = ftb.AnalysisBeamformer(testCase.out_folder);
           testCase.verifyEqual(a.steps,{});
           testCase.verifyEqual(a.out_folder,testCase.out_folder);
        end
        
        function test_add1(testCase)
            % check one added step
            a = ftb.AnalysisBeamformer(testCase.out_folder);
            step = ftb.tests.create_test_mri();
            a.add(step);
            testCase.verifyEqual(length(a.steps),1);
            testCase.verifyEqual(a.steps{1}, step);
            testCase.verifyEqual(a.steps{1}.prev, []);
            
        end
        
        function test_add2(testCase)
            % check two added steps
            a = ftb.AnalysisBeamformer(testCase.out_folder);
            step1 = ftb.tests.create_test_mri();
            a.add(step1);
            step2 = ftb.tests.create_test_hm();
            a.add(step2);
            testCase.verifyEqual(length(a.steps),2);
            testCase.verifyEqual(a.steps{1}, step1);
            testCase.verifyEqual(a.steps{2}, step2);
            testCase.verifyEqual(a.steps{2}.prev, step1);
        end
        
        function test_init(testCase)
            a = ftb.AnalysisBeamformer(testCase.out_folder);
            step = ftb.tests.create_test_mri();
            a.add(step);
            a.init();
            testCase.verifyEqual(a.steps{1}.init_called, true);
        end
        
%         function test_process(testCase)
%             a = ftb.AnalysisBeamformer();
%             testCase.verifyError(@()a.process(),'fb:AnalysisStep');
%         end
    end
    
end