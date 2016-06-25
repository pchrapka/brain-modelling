classdef Test_ft_trialfun_preceed < matlab.unittest.TestCase
    properties
        config;
        dataset;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            
            % subject specific info
            [datadir,subject_file,~] = get_coma_data(22);
            
            testCase.dataset = fullfile(datadir,[subject_file '-MMNf.eeg']);

            % error free config
            testCase.config = [];
            testCase.config.dataset = testCase.dataset;
            
            testCase.config.trialdef.eventtype = 'Stimulus';
            testCase.config.trialdef.eventvalue = 'S 11'; % standard
            testCase.config.trialpost.eventtype = 'Stimulus';
            testCase.config.trialpost.eventvalue = 'S 16'; % deviant
            
            testCase.config.trialdef.prestim = 0.2; % in seconds
            testCase.config.trialdef.poststim = 0.5; % in seconds

        end
    end
    
    methods (Test)
        function test_ft_trialfun_preceed(testCase)
            cfg = testCase.config;
            
            [trl,event] = ft_trialfun_preceed(cfg);
            
            testCase.verifyEqual(size(trl),[279 3]);
            testCase.verifyFalse(isempty(event));
        end
        
        function test_ft_definetrial(testCase)
            cfg = testCase.config;
            cfg.trialfun = 'ft_trialfun_preceed';
            
            cfgout = ft_definetrial(cfg);
            
            testCase.verifyEqual(size(cfgout.trl),[279 3]);
            testCase.verifyFalse(isempty(cfgout.event));
        end
        
        function test_ft_trialfun_preceed_error_trialpost_eventvalue(testCase)
            cfg = testCase.config;
            
            cfg.trialpost.eventvalue = {'S 16'}; % deviant
            testCase.verifyError(@() ft_trialfun_preceed(cfg),...
                'ft_trialfun_preceed:trialpost');
            
            cfg.trialpost.eventvalue = {'S 16','S 11'};
            testCase.verifyError(@() ft_trialfun_preceed(cfg),...
                'ft_trialfun_preceed:trialpost');
        end
        
        function test_ft_trialfun_preceed_error_dataset(testCase)
            cfg = testCase.config;
            cfg.dataset = '';
            
            testCase.verifyError(@() ft_trialfun_preceed(cfg),...
                'MATLAB:nonExistentField');
        end
        
        function test_ft_trialfun_preceed_error_trialpost(testCase)
            cfg = testCase.config;
            cfg = rmfield(cfg,'trialpost');
            testCase.verifyError(@() ft_trialfun_preceed(cfg),...
                'MATLAB:nonExistentField');
            
            cfg = testCase.config;
            cfg.trialpost = [];
            testCase.verifyError(@() ft_trialfun_preceed(cfg),...
                'MATLAB:nonStrucReference');
        end
        
        function test_ft_trialfun_preceed_error_trialdef(testCase)
            cfg = testCase.config;
            cfg = rmfield(cfg,'trialdef');
            testCase.verifyError(@() ft_trialfun_preceed(cfg),...
                'MATLAB:nonExistentField');
            
            cfg = testCase.config;
            cfg.trialdef = [];
            testCase.verifyError(@() ft_trialfun_preceed(cfg),...
                'MATLAB:nonStrucReference');
        end
        
%         function test_ft_definetrial(testCase)
%             % TODO
%         end
    end
end