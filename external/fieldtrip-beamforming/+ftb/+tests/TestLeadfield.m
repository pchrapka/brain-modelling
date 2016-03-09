classdef TestLeadfield < matlab.unittest.TestCase
    
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
            resolution = 5;
            cfg.ft_prepare_leadfield.grid.xgrid = -60:resolution:110;
            cfg.ft_prepare_leadfield.grid.ygrid = -70:resolution:60;
            cfg.ft_prepare_leadfield.grid.zgrid = -10:resolution:120;
            % cfg.ft_prepare_leadfield.grid.resolution = 5;
            cfg.ft_prepare_leadfield.grid.unit = 'mm';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'Test5mm';
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testCase.out_folder,'L5mm-test.mat');
            
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
           a = ftb.Leadfield(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'L');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_leadfield'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.leadfield));
        end
        
        function test_constructor2(testCase)
           a = ftb.Leadfield(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'L');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_leadfield'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.leadfield));
        end
        
        function test_init1(testCase)
            % check init throws error
            a = ftb.Leadfield(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),'ftb:Leadfield');
        end
        
        function test_init2(testCase)
            % check init works
            a = ftb.Leadfield(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.init_called,true);
            testCase.verifyTrue(~isempty(a.leadfield));
        end
        
        function test_init3(testCase)
            % check that get_name is used inside init
            a = ftb.Leadfield(testCase.params, testCase.name);
            a.add_prev(ftb.tests.create_test_elec());
            n = a.get_name();
            a.init(testCase.out_folder);
            
            [pathstr,~,~] = fileparts(a.leadfield);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
        end
        
        function test_add_prev(testCase)
            a = ftb.Leadfield(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            
            a.add_prev(ftb.tests.create_test_elec());
            testCase.verifyTrue(isa(a.prev,'ftb.Electrodes'));
            testCase.verifyTrue(isfield(a.prev.config, 'elec_orig'));
        end
        
        function test_add_prev_error(testCase)
            a = ftb.Leadfield(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            testCase.verifyError(@()a.add_prev(ftb.tests.create_test_leadfield()),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_name1(testCase)
            a = ftb.Leadfield(testCase.params, testCase.name);
            n = a.get_name();
            testCase.verifyEqual(n, ['L' testCase.name]);
        end
        
        function test_get_name2(testCase)
            a = ftb.Leadfield(testCase.params, testCase.name);
            e = ftb.tests.create_test_elec();
            a.add_prev(e);
            n = a.get_name();
            testCase.verifyEqual(n, ['E' e.name '-L' testCase.name]);
        end
        
        function test_process1(testCase)
            a = ftb.Leadfield(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:Leadfield');
        end
        
        function test_process2(testCase)
            a = ftb.Leadfield(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end