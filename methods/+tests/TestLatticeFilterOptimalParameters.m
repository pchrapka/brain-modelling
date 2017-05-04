classdef TestLatticeFilterOptimalParameters < matlab.unittest.TestCase
    
    properties
        tune_file = 'test-tune-file.mat';
    end
    
    methods (TestMethodSetup)
        function setup(testCase)
            nchannels = 4;
            nsamples = 100;
            data = zeros(nchannels,nsamples);
            save(testCase.tune_file,'data');
        end
        
    end
    methods (TestMethodTeardown)
        function close(testCase)
            if exist(testCase.tune_file,'file')
                delete(testCase.tune_file);
            end
        end
    end
    
    methods (Test)
        function test_LatticeFilterOptimalParameters(testCase)
            ntrials = 1;
            t = LatticeFilterOptimalParameters(testCase.tune_file,ntrials);
            
            testCase.verifyEmpty(t.opt_params_order);
            testCase.verifyEmpty(t.opt_params_lambda);
            testCase.verifyEmpty(t.opt_params_gamma);
            testCase.verifyEqual(t.tune_file,testCase.tune_file);
            testCase.verifyEqual(t.opt_params_file,...
                fullfile(t.tune_outdir,sprintf('opt-params-ntrials%d.mat',ntrials)));
        end
        
        function test_LatticeFilterOptimalParameters_get_order(testCase)
            ntrials = 1;
            t = LatticeFilterOptimalParameters(testCase.tune_file,ntrials);
            
            lambda = 5;
            order = 4;
            gamma = 3;
            
            testCase.verifyError(...
                @() t.get_opt('order','lambda',lambda),'MATLAB:InputParser:UnmatchedParameter');
            
            testCase.verifyError(...
                @() t.get_opt('order','gamma',gamma),'MATLAB:InputParser:UnmatchedParameter');
            
            value = t.get_opt('order');
            testCase.verifyEqual(value,NaN);
            
            t.set_opt('order',order);
            value = t.get_opt('order');
            testCase.verifyEqual(value,order);
        end
        
        function test_LatticeFilterOptimalParameters_get_lambda(testCase)
            ntrials = 1;
            t = LatticeFilterOptimalParameters(testCase.tune_file,ntrials);
            
            lambda = 5;
            order = 4;
            gamma = 3;
            
            testCase.verifyError(...
                @() t.get_opt('lambda'),'MATLAB:InputParser:notEnoughInputs');
            
            testCase.verifyError(...
                @() t.get_opt('lambda','gamma',gamma),'MATLAB:InputParser:UnmatchedParameter');
            
            value = t.get_opt('lambda','order',order);
            testCase.verifyEqual(value,NaN);
            
            t.set_opt('lambda',lambda,'order',order);
            value = t.get_opt('lambda','order',order);
            testCase.verifyEqual(value,lambda);
            
            t.set_opt('lambda',lambda,'order',order);
            t.set_opt('lambda',lambda+1,'order',order+1);
            t.set_opt('lambda',lambda+2,'order',order+2);
            value = t.get_opt('lambda','order',order);
            testCase.verifyEqual(value,lambda);
            value = t.get_opt('lambda','order',order+1);
            testCase.verifyEqual(value,lambda+1);
            value = t.get_opt('lambda','order',order+2);
            testCase.verifyEqual(value,lambda+2);
        end
        
        function test_LatticeFilterOptimalParameters_get_gamma(testCase)
            ntrials = 1;
            t = LatticeFilterOptimalParameters(testCase.tune_file,ntrials);
            
            lambda = 5;
            order = 4;
            gamma = 3;
            
            testCase.verifyError(...
                @() t.get_opt('gamma'),'MATLAB:InputParser:notEnoughInputs');
            
            testCase.verifyError(...
                @() t.get_opt('gamma','lambda',lambda),'MATLAB:InputParser:notEnoughInputs');
            
            testCase.verifyError(...
                @() t.get_opt('gamma','order',order),'MATLAB:InputParser:notEnoughInputs');
            
            value = t.get_opt('gamma','order',order,'lambda',lambda);
            testCase.verifyEqual(value,NaN);
            
            t.set_opt('gamma',gamma,'lambda',lambda,'order',order);
            value = t.get_opt('gamma','lambda',lambda,'order',order);
            testCase.verifyEqual(value,gamma);
            
            t.set_opt('gamma',gamma,'lambda',lambda,'order',order);
            t.set_opt('gamma',gamma+1,'lambda',lambda+1,'order',order);
            t.set_opt('gamma',gamma+2,'lambda',lambda+1,'order',order+1);
            value = t.get_opt('gamma','lambda',lambda,'order',order);
            testCase.verifyEqual(value,gamma);
            value = t.get_opt('gamma','lambda',lambda+1,'order',order);
            testCase.verifyEqual(value,gamma+1);
            value = t.get_opt('gamma','lambda',lambda+1,'order',order+1);
            testCase.verifyEqual(value,gamma+2);
        end
        
        function test_LatticeFilterOptimalParameters_set_error(testCase)
            ntrials = 1;
            t = LatticeFilterOptimalParameters(testCase.tune_file,ntrials);
            
            lambda = 5;
            order = 4;
            gamma = 3;
            
            % set order
            testCase.verifyError(...
                @() t.set_opt('order'),'MATLAB:minrhs');
            
            testCase.verifyError(...
                @() t.set_opt('order',order,'lambda',lambda),'MATLAB:InputParser:UnmatchedParameter');
            
            testCase.verifyError(...
                @() t.set_opt('order',order,'gamma',gamma),'MATLAB:InputParser:UnmatchedParameter');
            
            % set lambda
            testCase.verifyError(...
                @() t.set_opt('lambda',lambda,'gamma',gamma),'MATLAB:InputParser:UnmatchedParameter');
            
            testCase.verifyError(...
                @() t.set_opt('lambda'),'MATLAB:minrhs');
            
            % set gamma
            testCase.verifyError(...
                @() t.set_opt('gamma',gamma,'lambda',lambda),'MATLAB:InputParser:notEnoughInputs');
            
            testCase.verifyError(...
                @() t.set_opt('gamma',gamma,'order',order),'MATLAB:InputParser:notEnoughInputs');
            
            testCase.verifyError(...
                @() t.set_opt('gamma'),'MATLAB:minrhs');

        end
    end
    
end