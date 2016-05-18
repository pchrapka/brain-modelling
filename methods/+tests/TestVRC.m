classdef TestVRC < matlab.unittest.TestCase
    %TestVRC Summary of this class goes here
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
        function test_VRC(testCase)
            K = 4;
            order = 3;
            % test constructor
            s = VRC(K,order);
            testCase.verifyFalse(s.init);
            testCase.verifyEqual(s.K, K);
            testCase.verifyEqual(s.P, order);
            testCase.verifyEqual(size(s.Kf), [K,K,order]);
            testCase.verifyEqual(size(s.Kb), [K,K,order]);
        end
        
        function test_simulate(testCase)
            K = 4;
            order = 3;
            % test constructor
            s = VRC(K,order);
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
            Kf = randn(K,K,order);
            Kb = randn(K,K,order);

            s = VRC(K,order);
            s.coefs_set(Kf,Kb);
            
            testCase.verifyEqual(s.Kf,Kf);
            testCase.verifyEqual(s.Kb,Kb);
        end
        
        function test_coefs_set_error_Kf(testCase)
            K = 4;
            order = 3;
            Kf = randn(K-1,K,order);
            Kb = randn(K,K,order);

            s = VRC(K,order);
            testCase.verifyError(@() s.coefs_set(Kf,Kb),'VRC:ParamError');
        end
        
        function test_coefs_set_error_Kb(testCase)
            K = 4;
            order = 3;
            Kb = randn(K-1,K,order);
            Kf = randn(K,K,order);

            s = VRC(K,order);
            testCase.verifyError(@() s.coefs_set(Kf,Kb),'VRC:ParamError');
        end
        
%         function test_add_error_fake(testCase)
%             % test add error, try adding missing feature method
%             lf = LatticeFeatures(testCase.data);
%             testCase.verifyError(@() lf.add('aaa'),'MATLAB:noSuchMethodOrField');
%         end
    end
    
%    methods (Test, ParameterCombination='sequential')
        
%         function test_add(testCase,feat_name,feat_size)
%             % test all features and output sizes
%             lf = LatticeFeatures(testCase.data);
%             lf.add(feat_name);
%             
%             n = prod(testCase.dims(2:end))*feat_size;
%             testCase.verifyEqual(size(lf.features),[n 1]);
%             testCase.verifyEqual(size(lf.labels),[n 1]);
%             testCase.verifyEqual(lf.features_added{1},feat_name);
%             
%         end
%    end
    
end

