classdef TestHeadmodel < matlab.unittest.TestCase
    
    properties
        params;
        name;
        prev;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            % set up config
            cfg = [];
            cfg.ft_prepare_headmodel.method = 'bemcp';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'bemcp';
            testCase.prev = ftb.tests.create_test_mri();
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testCase.out_folder,'HMbemcp-test.mat');
            
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
           a = ftb.Headmodel(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'HM');
           testCase.verifyEqual(a.name,'bemcp');
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_headmodel'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.mri_headmodel));
        end
        
        function test_constructor2(testCase)
           a = ftb.Headmodel(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'HM');
           testCase.verifyEqual(a.name,'bemcp');
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_headmodel'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.mri_headmodel));
        end
        
        function test_init1(testCase)
            % check init throws error
            a = ftb.Headmodel(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),'ftb:Headmodel');
        end
        
        function test_init2(testCase)
            % check init works
            a = ftb.Headmodel(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.init_called,true);
            testCase.verifyTrue(~isempty(a.mri_headmodel));
        end
        
        function test_init3(testCase)
            % check that get_name is used inside init
            a = ftb.Headmodel(testCase.params, testCase.name);
            a.add_prev(ftb.tests.create_test_mri());
            n = a.get_name();
            a.init(testCase.out_folder);
            
            [pathstr,~,~] = fileparts(a.mri_headmodel);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
        end
        
        function test_add_prev(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            
            a.add_prev(testCase.prev);
            testCase.verifyTrue(isa(a.prev,'ftb.MRI'));
            testCase.verifyTrue(isfield(a.prev.config, 'ft_prepare_mesh'));
        end
        
        function test_add_prev_error(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            testCase.verifyError(@()a.add_prev(ftb.tests.create_test_hm()),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_name1(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name);
            n = a.get_name();
            testCase.verifyEqual(n, ['HM' testCase.name]);
        end
        
        function test_get_name2(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name);
            e = ftb.tests.create_test_mri();
            a.add_prev(e);
            n = a.get_name();
            testCase.verifyEqual(n, ['MRI' e.name '-HM' testCase.name]);
        end
        
        function test_process1(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:Headmodel');
        end
        
        function test_process2(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end