classdef TestElectrodes < matlab.unittest.TestCase
    
    properties
        params;
        name;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            % set up config
            cfg = [];
            cfg.elec_orig = 'GSN-HydroCel-256.sfp';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'Test256';
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testCase.out_folder,'E256-test.mat');
            
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
           a = ftb.Electrodes(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'E');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'elec_orig'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.elec));
           testCase.verifyTrue(isempty(a.elec_aligned));
        end
        
        function test_constructor2(testCase)
           a = ftb.Electrodes(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'E');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'elec_orig'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.elec));
           testCase.verifyTrue(isempty(a.elec_aligned));
        end
        
        function test_init1(testCase)
            % check init throws error
            a = ftb.Electrodes(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),'ftb:Electrodes');
        end
        
        function test_init2(testCase)
            % check init works
            a = ftb.Electrodes(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.init_called,true);
            testCase.verifyTrue(~isempty(a.elec));
            testCase.verifyTrue(~isempty(a.elec_aligned));
        end
        
        function test_init3(testCase)
            % check that get_name is used inside init
            a = ftb.Electrodes(testCase.params, testCase.name);
            a.add_prev(ftb.tests.create_test_hm());
            n = a.get_name();
            a.init(testCase.out_folder);
            
            [pathstr,~,~] = fileparts(a.elec);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
        end
        
        function test_add_prev(testCase)
            a = ftb.Electrodes(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            
            a.add_prev(ftb.tests.create_test_hm());
            testCase.verifyTrue(isa(a.prev,'ftb.Headmodel'));
            testCase.verifyTrue(isfield(a.prev.config, 'ft_prepare_headmodel'));
        end
        
        function test_add_prev_error(testCase)
            a = ftb.Electrodes(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            testCase.verifyError(@()a.add_prev(ftb.tests.create_test_elec()),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_name1(testCase)
            a = ftb.Electrodes(testCase.params, testCase.name);
            n = a.get_name();
            testCase.verifyEqual(n, ['E' testCase.name]);
        end
        
        function test_get_name2(testCase)
            a = ftb.Electrodes(testCase.params, testCase.name);
            e = ftb.tests.create_test_hm();
            a.add_prev(e);
            n = a.get_name();
            testCase.verifyEqual(n, ['HM' e.name '-E' testCase.name]);
        end
        
        function test_process1(testCase)
            a = ftb.Electrodes(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:Electrodes');
        end
        
        function test_process2(testCase)
            a = ftb.Electrodes(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end