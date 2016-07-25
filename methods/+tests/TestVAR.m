classdef TestVAR < matlab.unittest.TestCase
    %TestVAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
%         dims;
%         data;
    end
    
    properties (TestParameter)
        %Kf = {};
        %Kb = {};
    end
    
    methods (TestClassSetup)
        function setup(testCase)
%             nsamples = 4;
%             norder = 3;
%             nchannels = 5;
%             testCase.dims = [nsamples, norder, nchannels, nchannels];
%             testCase.data = randn(testCase.dims);
        end
    end
    
    methods (TestClassTeardown)
    end
    
    methods (Test)
        function test_VAR(testCase)
            K = 4;
            order = 3;
            % test constructor
            s = VAR(K,order);
            testCase.verifyFalse(s.init);
            testCase.verifyEqual(s.K, K);
            testCase.verifyEqual(s.P, order);
            testCase.verifyEqual(size(s.A), [K,K,order]);
        end
        
         function test_sparse_stable(testCase)
            K = 4;
            order = 3;
            % test constructor
            s = VAR(K,order);
            s.coefs_gen_sparse('mode','exact','ncoefs',6,'stable',true);
         end
        
         function test_sparse_stable_large(testCase)
            K = 13;
            order = 8;
            sparsity = 0.1;
            ncoefs = ceil(K^2*order*sparsity);
            % test constructor
            s = VAR(K,order);
            s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs,'stable',true,'verbose',1);
            
            ncoefs_var = abs(s.A(:)) > 0;
            testCase.verifyEqual(ncoefs,sum(ncoefs_var));
         end
        
         function test_gen_sparse_fullchannels(testCase)
            K = 13;
            order = 8;
            sparsity = 0.1;
            
            ncoefs = ceil(K^2*order*sparsity);
            ncouplings = floor(ncoefs/4);
            
            s = VAR(K,order);
            s.coefs_gen_sparse('mode','exact',...
                'structure','fullchannels',...
                'ncoefs',ncoefs,...
                'ncouplings',ncouplings,...
                'stable',true,...
                'verbose',1);
            
            ncoefs_var = abs(s.A(:)) > 0;
            testCase.verifyGreaterThanOrEqual(sum(ncoefs_var),ncoefs-K);
        end
        
        function test_simulate(testCase)
            K = 4;
            order = 3;
            % test constructor
            s = VAR(K,order);
            s.coefs_gen_sparse('mode','exact','ncoefs',6);
            
            nsamples = 100;
            [y, y_norm, noise] = s.simulate(nsamples);
            testCase.verifyEqual(size(y), [K, nsamples]);
            testCase.verifyEqual(size(y_norm), [K, nsamples]);
            testCase.verifyEqual(size(noise), [K, nsamples]);
            
            figure;
            for i=1:K
                subplot(K,1,i);
                plot(1:nsamples,y(i,:));
            end
        end
        
        function test_coefs_set(testCase)
            K = 4;
            order = 3;
            A = randn(K,K,order);

            s = VAR(K,order);
            s.coefs_set(A);
            
            testCase.verifyEqual(s.A,A);
        end
        
        function test_coefs_set_error(testCase)
            K = 4;
            order = 3;
            A = randn(K-1,K,order);
            A1 = randn(K,K,order+1);

            s = VAR(K,order);
            testCase.verifyError(@() s.coefs_set(A),'VAR:ParamError');
            testCase.verifyError(@() s.coefs_set(A1),'VAR:ParamError');
        end
        
    end
    
    
end

