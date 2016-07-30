classdef TestMRI < matlab.unittest.TestCase
    
    properties
        params;
        name;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            cfg = [];
            
            % Processing options
            cfg.ft_volumesegment.output = {'brain','skull','scalp'};
            cfg.ft_prepare_mesh.method = 'projectmesh';
            cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
            cfg.ft_prepare_mesh.numvertices = [2000, 1500, 1000];
            % MRI data
            cfg.mri_data = 'mrifile.mat';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'TestMRI';
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testCase.out_folder,'MRI-test.mat');
            
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
           a = ftb.MRI(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'MRI');
           testCase.verifyEqual(a.name,'TestMRI');
           testCase.verifyEqual(a.config.mri_data,'mrifile.mat');
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_mesh'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.mri_mat));
           testCase.verifyTrue(isempty(a.mri_segmented));
           testCase.verifyTrue(isempty(a.mri_mesh));
        end
        
        function test_constructor2(testCase)
           a = ftb.MRI(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'MRI');
           testCase.verifyEqual(a.name,'TestMRI');
           testCase.verifyEqual(a.config.mri_data,'mrifile.mat');
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_mesh'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.mri_mat));
           testCase.verifyTrue(isempty(a.mri_segmented));
           testCase.verifyTrue(isempty(a.mri_mesh));
        end
        
        function test_init1(testCase)
            % check init throws error
            a = ftb.MRI(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_init2(testCase)
            % check init works
            a = ftb.MRI(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.init_called,true);
            testCase.verifyTrue(~isempty(a.mri_mat));
            testCase.verifyTrue(~isempty(a.mri_segmented));
            testCase.verifyTrue(~isempty(a.mri_mesh));
        end
        
        function test_init3(testCase)
            % check that get_name is used inside init
            a = ftb.MRI(testCase.params, testCase.name);
            n = a.get_name();
            a.init(testCase.out_folder);
            
            [pathstr,~,~] = fileparts(a.mri_mat);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
        end
        
        function test_get_name(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            n = a.get_name();
            testCase.verifyEqual(n, ['MRI' testCase.name]);
        end
        
        function test_add_prev(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            a.add_prev([]);
            testCase.verifyEqual(a.prev,[]);
        end
        
        function test_add_prev_error(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            testCase.verifyError(@()a.add_prev(ftb.tests.create_test_mri()),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_process1(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:MRI');
        end
        
        function test_process2(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end