classdef get_metric_idx_test < matlab.unittest.TestCase
    
    properties
        data;
    end
    
    methods(TestMethodSetup)
        
        function setUp(testcase)
            % Create the data struct
            k = 1;
            testcase.data.metrics{k}.name = 'fft';
            k = k+1;
            
            testcase.data.metrics{k}.name = 'fft1';
            k = k+1;
            
            testcase.data.metrics{k}.name = 'gmfa';
            testcase.data.metrics{k}.interval_start = 5;
            testcase.data.metrics{k}.interval_end = 10;
            k = k+1;
            
            testcase.data.metrics{k}.name = 'gmfa';
            testcase.data.metrics{k}.interval_start = 5;
            testcase.data.metrics{k}.interval_end = 15;
            k = k+1;
            
            testcase.data.metrics{k}.name = 'fft1';
            k = k+1;
            
            testcase.data.metrics{k}.name = 'gmfa';
            testcase.data.metrics{k}.interval_start = 7;
            testcase.data.metrics{k}.interval_end = 10;
            k = k+1;
        end
        
    end

    methods(Test)
        function test_basic(testcase)
            
            % test fft
            cfg = [];
            cfg.name = 'fft';
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEqual(idx, 1, 'Error with basic searching');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEqual(idx, [3 4 6], 'Error with basic searching');
            
            % test fft1
            cfg = [];
            cfg.name = 'fft1';
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEqual(idx, [2 5], 'Error with basic searching');
            
        end
        
        function test_advanced(testcase)
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_start = 5;
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEqual(idx, [3 4], 'Error with basic searching');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_end = 10;
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEqual(idx, [3 6], 'Error with basic searching');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_start = 5;
            cfg.interval_end = 10;
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEqual(idx, 3, 'Error with basic searching');
            
            % test fft
            cfg = [];
            cfg.name = 'fft';
            cfg.interval_start = 5;
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEmpty(idx, 'Error with basic searching');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_start = 6;
            cfg.interval_end = 11;
            idx = lumberjack.get_metric_idx(cfg, testcase.data);
            testcase.verifyEmpty(idx, 'Error with basic searching');
        end
        
    end
       
    methods(TestMethodTeardown)
        function tearDown(testcase)
            % Nothing to do
        end
        
    end
    
end