classdef check_metric_test < matlab.unittest.TestCase
    
    properties
        data;
    end
    
    methods(TestMethodSetup)
        
        function setUp(testcase)
            % Create the data struct
            k = 1;
            testcase.data.metrics{k}.name = 'fft';
            k = k+1;
            
            testcase.data.metrics{k}.name = 'gmfa';
            testcase.data.metrics{k}.interval_start = 5;
            testcase.data.metrics{k}.interval_end = 10;
            k = k+1;
            
            testcase.data.metrics{k}.name = 'gmfa';
            testcase.data.metrics{k}.interval_start = 10;
            testcase.data.metrics{k}.interval_end = 15;
            k = k+1;
            
            testcase.data.metrics{k}.name = 'gmfa';
            testcase.data.metrics{k}.interval_start = 7;
            testcase.data.metrics{k}.interval_end = 10;
            k = k+1;
        end
        
    end

    methods(Test)
        function test_basic(testcase)
            % Select a metric
            metric = testcase.data.metrics{1};
            
            % test fft
            cfg = [];
            cfg.name = 'fft';
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyTrue(out,  'Error with basic name checking');
            
            % test fft
            cfg = [];
            cfg.name = 'fft1';
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyFalse(out, 'Error with basic name checking');
            
            cfg = [];
            cfg.name = 'gmfa';
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyFalse(out, 'Error with basic name checking');
        end
        
        function test_basic2(testcase)
            % Select a metric
            metric = testcase.data.metrics{2};
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_start = 5;
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyTrue(out, 'Error with extra field checking');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_start = 6;
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyFalse(out, 'Error with extra field checking');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_end = 10;
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyTrue(out, 'Error with extra field checking');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_end = 11;
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyFalse(out, 'Error with extra field checking');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_start = 5;
            cfg.interval_end = 10;
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyTrue(out, 'Error with extra field checking');
            
            % test gmfa
            cfg = [];
            cfg.name = 'gmfa';
            cfg.interval_start = 6;
            cfg.interval_end = 11;
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyFalse(out, 'Error with extra field checking');
        end
        
        function test_bad_input(testcase)
            % Select a metric
            metric = testcase.data.metrics{1};
            
            % test fft
            cfg = [];
            cfg.name = 'fft';
            cfg.interval_start = 5;
            out = lumberjack.check_metric(cfg, metric);
            testcase.verifyFalse(out,  'Error with basic name checking');
        end
        
    end
       
    methods(TestMethodTeardown)
        function tearDown(testcase)
            % Nothing to do
        end
        
    end
    
end