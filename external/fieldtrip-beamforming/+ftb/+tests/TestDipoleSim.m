classdef TestDipoleSim < matlab.unittest.TestCase
    
    properties
        params;
        name;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            % set up config
            unit = 'mm';
            if isequal(unit, 'cm')
                scale = 0.1; % for cm
            elseif isequal(unit, 'mm')
                scale = 1; % for mm
            else
                error(['ftb:' mfilename],...
                    'unknown unit %s', unit);
            end
            
            k = 1;
            dip(k).pos = scale*[-50 -10 50]; % mm
            dip(k).mom = dip(k).pos/norm(dip(k).pos);
            
            nsamples = 1000;
            trials = 1;
            fsample = 250; %Hz
            triallength = nsamples/fsample;
            
            cfg = [];
            cfg.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
            cfg.ft_dipolesimulation.dip.mom = [dip(1).mom]';
            cfg.ft_dipolesimulation.dip.unit = unit;
            cfg.ft_dipolesimulation.dip.frequency = 10;
            cfg.ft_dipolesimulation.dip.phase = 0;
            cfg.ft_dipolesimulation.dip.amplitude = 1*70;
            cfg.ft_dipolesimulation.fsample = fsample;
            cfg.ft_dipolesimulation.ntrials = trials;
            cfg.ft_dipolesimulation.triallength = triallength;
            cfg.ft_dipolesimulation.absnoise = 0.01;
            
            cfg.ft_timelockanalysis.covariance = 'yes';
            cfg.ft_timelockanalysis.covariancewindow = 'all';
            cfg.ft_timelockanalysis.keeptrials = 'no';
            cfg.ft_timelockanalysis.removemean = 'yes';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'Test5mm';
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testCase.out_folder,'DSsine-test.mat');
            
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
           a = ftb.DipoleSim(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'DS');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_dipolesimulation'));
           testCase.verifyTrue(isfield(a.config, 'ft_timelockanalysis'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.simulated));
           testCase.verifyTrue(isempty(a.timelock));
        end
        
        function test_constructor2(testCase)
           a = ftb.DipoleSim(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'DS');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_dipolesimulation'));
           testCase.verifyTrue(isfield(a.config, 'ft_timelockanalysis'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.simulated));
           testCase.verifyTrue(isempty(a.timelock));
        end
        
        function test_init1(testCase)
            % check init throws error
            a = ftb.DipoleSim(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),'ftb:DipoleSim');
        end
        
        function test_init2(testCase)
            % check init works
            a = ftb.DipoleSim(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.init_called,true);
            testCase.verifyTrue(~isempty(a.simulated));
            testCase.verifyTrue(~isempty(a.timelock));
        end
        
        function test_init3(testCase)
            % check that get_name is used inside init
            a = ftb.DipoleSim(testCase.params, testCase.name);
            a.add_prev(ftb.tests.create_test_leadfield());
            n = a.get_name();
            a.init(testCase.out_folder);
            
            [pathstr,~,~] = fileparts(a.simulated);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
            [pathstr,~,~] = fileparts(a.timelock);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
        end
        
        function test_add_prev(testCase)
            a = ftb.DipoleSim(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            
            a.add_prev(ftb.tests.create_test_leadfield());
            testCase.verifyTrue(isa(a.prev,'ftb.Leadfield'));
            testCase.verifyTrue(isfield(a.prev.config, 'ft_prepare_leadfield'));
        end
        
        function test_get_name1(testCase)
            a = ftb.DipoleSim(testCase.params, testCase.name);
            n = a.get_name();
            testCase.verifyEqual(n, ['DS' testCase.name]);
        end
        
        function test_get_name2(testCase)
            a = ftb.DipoleSim(testCase.params, testCase.name);
            e = ftb.tests.create_test_leadfield();
            a.add_prev(e);
            n = a.get_name();
            testCase.verifyEqual(n, ['L' e.name '-DS' testCase.name]);
        end
        
        function test_process1(testCase)
            a = ftb.DipoleSim(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:DipoleSim');
        end
        
        function test_process2(testCase)
            a = ftb.DipoleSim(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end