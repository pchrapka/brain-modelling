classdef Test_plot_mse_vs_iteration < matlab.unittest.TestCase
    %Test_plot_mse_vs_iteration Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        estimate;
        truth;
    end
    
    properties (TestParameter)
        modes = {'plot','log'};
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
        function test_plot(testCase)
            % single data set
            figure;
            plot_mse_vs_iteration(testCase.estimate{1}, testCase.truth{1});
            title(strrep('test_plot','_',' '));
        end
        
        function test_plot2(testCase)
            % multiple data sets
            figure;
            plot_mse_vs_iteration(testCase.estimate{1}, testCase.truth{1},...
                testCase.estimate{2}, testCase.truth{2});
            title(strrep('test_plot2','_',' '));
        end
        
        function test_plot3(testCase)
            % multiple sims
            figure;
            plot_mse_vs_iteration(testCase.estimate, testCase.truth);
            title(strrep('test_plot3','_',' '));
        end
        
        function test_plot_mode(testCase,modes)
            figure;
            plot_mse_vs_iteration(testCase.estimate{1}, testCase.truth{1},...
                'mode',modes);
            title([strrep('test_plot_mode','_',' ') ' ' modes]);
        end
        
        function test_plot_labels(testCase)
            figure;
            plot_mse_vs_iteration(testCase.estimate{1}, testCase.truth{1},...
                testCase.estimate{2}, testCase.truth{2},...
                'labels',{'method1','method2'});
            title(strrep('test_plot_labels','_',' '));
        end
    end
    
end

