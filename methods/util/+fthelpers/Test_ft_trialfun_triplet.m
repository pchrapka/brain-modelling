classdef Test_ft_trialfun_triplet < matlab.unittest.TestCase
    properties
        config;
        dataset;
    end
    
    properties (TestParameter)
        trialfield = {'trialpre','trialmid','trialpost'};
    end
    
    
    methods (TestClassSetup)
        function setup(testCase)
            
            % subject specific info
            [data_file,~,~] = get_data_andrew(3,10);
            
            testCase.dataset = data_file;

            % error free config
            testCase.config = [];
            testCase.config.dataset = testCase.dataset;
            
            testCase.config.trialmid.eventtype = 'STATUS';
            testCase.config.trialmid.eventvalue = 1; % standard
            testCase.config.trialpre.eventtype = 'STATUS';
            testCase.config.trialpre.eventvalue = 1; % standard
            testCase.config.trialpost.eventtype = 'STATUS';
            testCase.config.trialpost.eventvalue = 1; % standard
            
            testCase.config.trialmid.prestim = 0.2; % in seconds
            testCase.config.trialmid.poststim = 0.5; % in seconds

        end
    end
    
    methods (Test)
        function test_ft_trialfun_triplet(testCase)
            cfg = testCase.config;
            
            [trl,event] = fthelpers.ft_trialfun_triplet(cfg);
            
            testCase.verifyEqual(size(trl),[2518 3]);
            testCase.verifyFalse(isempty(event));
        end
        
        function test_ft_trialfun_triplet_data(testCase)
            cfg = testCase.config;
            
            [trl,~] = fthelpers.ft_trialfun_triplet(cfg);
            
            % check trials found
            testCase.verifyEqual(trl(5,:),[109968 111401 -410]);
        end
        
        function test_ft_definetrial(testCase)
            cfg = testCase.config;
            cfg.trialfun = 'fthelpers.ft_trialfun_triplet';
            
            cfgout = ft_definetrial(cfg);
            
            testCase.verifyEqual(size(cfgout.trl),[2518 3]);
            testCase.verifyFalse(isempty(cfgout.event));
        end
        
        function test_ft_trialfun_triplet_error_eventvalue(testCase,trialfield)
            cfg = testCase.config;
            
            cfg.(trialfield).eventvalue = {'S 16'}; % deviant
            testCase.verifyError(@() fthelpers.ft_trialfun_triplet(cfg),...
                'ft_trialfun_triplet:input');
            
            cfg.(trialfield).eventvalue = {'S 16','S 11'};
            testCase.verifyError(@() fthelpers.ft_trialfun_triplet(cfg),...
                'ft_trialfun_triplet:input');
            
            cfg.(trialfield).eventvalue = [1 2];
            testCase.verifyError(@() fthelpers.ft_trialfun_triplet(cfg),...
                'ft_trialfun_triplet:input');
        end
        
        function test_ft_trialfun_triplet_error_dataset(testCase)
            cfg = testCase.config;
            cfg.dataset = '';
            
            testCase.verifyError(@() fthelpers.ft_trialfun_triplet(cfg),...
                'MATLAB:nonExistentField');
        end
        
        function test_ft_trialfun_triplet_error_trialfield(testCase,trialfield)
            cfg = testCase.config;
            cfg = rmfield(cfg,trialfield);
            testCase.verifyError(@() fthelpers.ft_trialfun_triplet(cfg),...
                'MATLAB:nonExistentField');
            
            cfg = testCase.config;
            cfg.(trialfield) = [];
            testCase.verifyError(@() fthelpers.ft_trialfun_triplet(cfg),...
                'MATLAB:nonStrucReference');
        end
        
%         function test_ft_definetrial(testCase)
%             % TODO
%         end
    end
end