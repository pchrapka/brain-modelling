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
            
            testCase.verifyEqual(length(pipe.config.bricks),5);
            testCase.verifyEqual(pipe.config.bricks(4).name,'bricks.features_validate');
            testCase.verifyEqual(pipe.config.bricks(4).id,'fv');
        end
        
        function test_expand_code(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            
            % mode = names
            job_name_full = pipe.expand_code(job_name);
            testCase.verifyEqual(job_name_full,'bricks.add_label-params_al_odd');
            
            job_name_full = pipe.expand_code(job_name,'expand','params');
            testCase.verifyEqual(job_name_full,'al-params_al_odd');
            job_name_full = pipe.expand_code(job_name,'mode','names','expand','params');
            testCase.verifyEqual(job_name_full,'al-params_al_odd');
            
            job_name_full = pipe.expand_code(job_name,'expand','bricks');
            testCase.verifyEqual(job_name_full,'bricks.add_label-01');
            job_name_full = pipe.expand_code(job_name,'mode','names','expand','bricks');
            testCase.verifyEqual(job_name_full,'bricks.add_label-01');
            
            % mode = folders
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','both');
            testCase.verifyEqual(job_name_full,'bricks.add-label-params-al-odd');
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(job_name_full,'al-params-al-odd');
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','bricks');
            testCase.verifyEqual(job_name_full,'bricks.add-label-01');
            
            % job 2
            job_name = pipe.add_job('bricks.add_label','params_al_std','files_in','fake.mat');
            
            job_name_full = pipe.expand_code(job_name,'expand','params');
            testCase.verifyEqual(job_name_full,'al-params_al_std');
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(job_name_full,'al-params-al-std');
        end
        
        function test_expand_code_2stage(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            
            job_name = pipe.add_job('bricks.lattice_filter_sources','params_lf_MQRDLSL2_p10_l099_n400',...
                'parent_job',job_name);
            
            % mode = names
            job_name_full = pipe.expand_code(job_name);
            testCase.verifyEqual(job_name_full,...
                ['bricks.add_label-params_al_odd'...
                '-bricks.lattice_filter_sources-params_lf_MQRDLSL2_p10_l099_n400']);
            
            job_name_full = pipe.expand_code(job_name,'expand','params');
            testCase.verifyEqual(job_name_full,...
                ['al-params_al_odd'...
                '-lf-params_lf_MQRDLSL2_p10_l099_n400']);
            job_name_full = pipe.expand_code(job_name,'mode','names','expand','params');
            testCase.verifyEqual(job_name_full,...
                ['al-params_al_odd'...
                '-lf-params_lf_MQRDLSL2_p10_l099_n400']);
            
            job_name_full = pipe.expand_code(job_name,'expand','bricks');
            testCase.verifyEqual(job_name_full,...
                ['bricks.add_label-01-'...
                'bricks.lattice_filter_sources-01']);
            job_name_full = pipe.expand_code(job_name,'mode','names','expand','bricks');
            testCase.verifyEqual(job_name_full,...
                ['bricks.add_label-01-'...
                'bricks.lattice_filter_sources-01']);
            
            % mode = folders
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','both');
            testCase.verifyEqual(job_name_full,...
                fullfile('bricks.add-label-params-al-odd',...
                'bricks.lattice-filter-sources-params-lf-MQRDLSL2-p10-l099-n400'));
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(job_name_full,...
                fullfile('al-params-al-odd','lf-params-lf-MQRDLSL2-p10-l099-n400'));
            
            job_name_full = pipe.expand_code(job_name,'mode','folders','expand','bricks');
            testCase.verifyEqual(job_name_full,...
                fullfile('bricks.add-label-01','bricks.lattice-filter-sources-01'));
        end
        
        function test_add_job_error(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            testCase.verifyError(...
                @() pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat'),...
                'PipelineLatticeSVM:add_job');
        end
        
        function test_add_job(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            
            testCase.verifyTrue(isfield(pipe.pipeline,job_name));
            testCase.verifyTrue(isfield(pipe.pipeline.(job_name),'outdir'));
            
            jobdir = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(pipe.pipeline.(job_name).outdir,jobdir);
            
            outdir = fullfile(pipe.outdir,jobdir);
            testCase.verifyGreaterThan(exist(outdir,'dir'),0);
        end
        
        function test_add_job_name(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            testCase.verifyEqual(job_name,'al01');
            
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_std','files_in','fake.mat');
            testCase.verifyEqual(job_name,'al02');
        end
        
        function test_add_job_2stage(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            
            job_name = pipe.add_job('bricks.lattice_filter_sources','params_lf_MQRDLSL2_p10_l099_n400',...
                'parent_job',job_name);
            
            testCase.verifyEqual(job_name,'al01lf01');
            
            testCase.verifyTrue(isfield(pipe.pipeline,job_name));
            testCase.verifyTrue(isfield(pipe.pipeline.(job_name),'outdir'));
            
            jobdir = pipe.expand_code(job_name,'mode','folders','expand','params');
            testCase.verifyEqual(pipe.pipeline.(job_name).outdir,jobdir);
            
            outdir = fullfile(pipe.outdir,jobdir);
            testCase.verifyGreaterThan(exist(outdir,'dir'),0);
        end
        
        function test_exist_job(testCase)
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            testCase.verifyTrue(pipe.exist_job(job_name));
            testCase.verifyFalse(pipe.exist_job('fakejob'));
        end
        
                
        function test_config(testCase)
            % check that config file is updated and persistent
            pipe = PipelineLatticeSVM(testCase.pipedir);
            job_name = pipe.add_job('bricks.add_label','params_al_odd','files_in','fake.mat');
            
            pipe2 = PipelineLatticeSVM(testCase.pipedir);
            testCase.verifyEqual(pipe2.config.bricks(1).params{1}.name,'params_al_odd');
        end
    end
    
end

