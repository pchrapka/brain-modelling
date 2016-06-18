classdef TestPipelineLatticeSVM < matlab.unittest.TestCase
    %TestPipelineLatticeSVM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pipedir;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            [path_str,~,~] = fileparts(mfilename('fullpath'));
            testCase.pipedir = fullfile(path_str,'pipetest');
        end
    end
    
    methods (TestClassTeardown)
        function delete(testCase)
            if exist(testCase.pipedir,'dir')
                rmdir(testCase.pipedir,'s');
            end
        end
    end
    
    methods (Test)
        function test_constructor(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            
            testCase.verifyGreaterThan(exist(pipe.outdir,'dir'),0);
            testCase.verifyGreaterThan(exist(pipe.config_file,'file'),0);
            
            testCase.verifyEqual(length(pipe.config.bricks),4);
            testCase.verifyEqual(pipe.config.bricks(4).name,'bricks.features_validate');
            testCase.verifyEqual(pipe.config.bricks(4).id,'fv');
        end
        
        function test_expand_code(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.select_trials','params_st_odd_10','files_in','fake.mat');
            
            % mode = names
            job_name_full = pipe.expand_code(job_name);
            testCase.verifyEqual(job_name_full,'bricks.select_trials-params_st_odd_10');
            
            job_name_full = pipe.expand_code(job_name,'expand','params');
            testCase.verifyEqual(job_name_full,'st-params_st_odd_10');
            job_name_full = pipe.expand_code(job_name,'mode','names','expand','params');
            testCase.verifyEqual(job_name_full,'st-params_st_odd_10');
            
            job_name_full = pipe.expand_code(job_name,'expand','bricks');
            testCase.verifyEqual(job_name_full,'bricks.select_trials-01');
            job_name_full = pipe.expand_code(job_name,'mode','names','expand','bricks');
            testCase.verifyEqual(job_name_full,'bricks.select_trials-01');
            
            % mode = folders
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','both');
            testCase.verifyEqual(job_name_full,'bricks.select-trials-params-st-odd-10');
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(job_name_full,'st-params-st-odd-10');
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','bricks');
            testCase.verifyEqual(job_name_full,'bricks.select-trials-01');
            
            % job 2
            job_name = pipe.add_job('bricks.select_trials','params_st_std_10','files_in','fake.mat');
            
            job_name_full = pipe.expand_code(job_name,'expand','params');
            testCase.verifyEqual(job_name_full,'st-params_st_std_10');
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(job_name_full,'st-params-st-std-10');
            
            % TODO add hierarchical test
        end
        
        function test_add_job_error(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            pipe.add_job('bricks.select_trials','params_st_odd_10','files_in','fake.mat');
            testCase.verifyError(...
                @() pipe.add_job('bricks.select_trials','params_st_odd_10','files_in','fake.mat'),...
                'PipelineLatticeSVM:add_job');
        end
        
        function test_add_job(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.select_trials','params_st_odd_10','files_in','fake.mat');
            
            testCase.verifyTrue(isfield(pipe.pipeline,job_name));
            testCase.verifyTrue(isfield(pipe.pipeline.(job_name),'outdir'));
            
            jobdir = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(pipe.pipeline.(job_name).outdir,jobdir);
            
            outdir = fullfile(pipe.outdir,jobdir);
            testCase.verifyGreaterThan(exist(outdir,'dir'),0);
        end
        
        function test_add_job_name(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.select_trials','params_st_odd_10','files_in','fake.mat');
            testCase.verifyEqual(job_name,'st01');
            
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.select_trials','params_st_std_10','files_in','fake.mat');
            testCase.verifyEqual(job_name,'st02');
        end
        
        
        function test_exist_job(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.select_trials','params_st_odd_10','files_in','fake.mat');
            testCase.verifyTrue(pipe.exist_job(job_name));
            testCase.verifyFalse(pipe.exist_job('fakejob'));
        end
    end
    
end

