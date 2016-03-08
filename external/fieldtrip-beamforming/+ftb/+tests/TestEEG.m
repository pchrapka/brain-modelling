classdef TestEEG < matlab.unittest.TestCase
    
    properties
        params;
        name;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            
            cfg = [];
            cfg.ft_definetrial = [];
            % TODO Add real data?
            %cfg.ft_definetrial.dataset = ;
            %cfg.ft_definetrial.trialdef.eventtype = 'Stimulus';
            %cfg.ft_definetrial.trialdef.eventvalue = {'S 11'};
            %cfg.ft_definetrial.trialdef.prestim = 0.4; % in seconds
            %cfg.ft_definetrial.trialdef.poststim = 1; % in seconds
            
            cfg.ft_preprocessing = [];
            cfg.ft_preprocessing.method = 'trial';
            cfg.ft_preprocessing.continuous = 'no';
            cfg.ft_preprocessing.detrend = 'no';
            cfg.ft_preprocessing.demean = 'no';
            cfg.ft_preprocessing.channel = 'EEG';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'test';
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testCase.out_folder,'EEGtest.mat');
            
            % create output folder
            if ~exist(testCase.out_folder,'dir')
                mkdir(testCase.out_folder)
            end
            
            % create test config file
            save(testCase.paramfile,'cfg');
        end
    end
    
    methods(TestClassTeardown)
        function delete_files(testCase)
            rmdir(testCase.out_folder,'s');
        end
    end
    
    methods (Test)
        function test_constructor1(testCase)
           a = ftb.EEG(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'EEG');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_definetrial'));
           testCase.verifyTrue(isfield(a.config, 'ft_preprocessing'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.definetrial));
           testCase.verifyTrue(isempty(a.preprocessed));
           testCase.verifyTrue(isempty(a.timelock));
        end
        
        function test_constructor2(testCase)
           a = ftb.EEG(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'EEG');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_definetrial'));
           testCase.verifyTrue(isfield(a.config, 'ft_preprocessing'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.definetrial));
           testCase.verifyTrue(isempty(a.preprocessed));
           testCase.verifyTrue(isempty(a.timelock));
        end
        
        function test_init1(testCase)
            % check init throws error
            a = ftb.EEG(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),'ftb:EEG');
        end
        
        function test_init2(testCase)
            % check init works
            a = ftb.EEG(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.init_called,true);
            testCase.verifyTrue(~isempty(a.definetrial));
            testCase.verifyTrue(~isempty(a.preprocessed));
            testCase.verifyTrue(~isempty(a.timelock));
        end
        
        function test_init3(testCase)
            % check that get_name is used inside init
            a = ftb.EEG(testCase.params, testCase.name);
            a.add_prev(ftb.tests.create_test_leadfield());
            n = a.get_name();
            a.init(testCase.out_folder);
            
            [pathstr,~,~] = fileparts(a.definetrial);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
            [pathstr,~,~] = fileparts(a.preprocessed);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
            [pathstr,~,~] = fileparts(a.timelock);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
        end
        
        function test_add_prev(testCase)
            a = ftb.EEG(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            
            a.add_prev(ftb.tests.create_test_leadfield());
            testCase.verifyTrue(isa(a.prev,'ftb.Leadfield'));
            testCase.verifyTrue(isfield(a.prev.config, 'ft_prepare_leadfield'));
        end
        
        function test_add_prev_error(testCase)
            a = ftb.EEG(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            testCase.verifyError(@()a.add_prev(ftb.tests.create_test_elec()),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_name1(testCase)
            a = ftb.EEG(testCase.params, testCase.name);
            n = a.get_name();
            testCase.verifyEqual(n, ['EEG' testCase.name]);
        end
        
        function test_get_name2(testCase)
            a = ftb.EEG(testCase.params, testCase.name);
            e = ftb.tests.create_test_leadfield();
            a.add_prev(e);
            n = a.get_name();
            testCase.verifyEqual(n, ['L' e.name '-EEG' testCase.name]);
        end
        
        function test_process1(testCase)
            a = ftb.EEG(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:EEG');
        end
        
        function test_process2(testCase)
            a = ftb.EEG(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end