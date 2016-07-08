classdef Test_plot_rc_feature_matrix < matlab.unittest.TestCase
    %Test_plot_rc_feature_matrix Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data;
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            niterations = 5;
            norder = 3;
            nchannels = 4;
            
            nsamples = 100;
            nfeatures = niterations*norder*nchannels^2;
            
            testCase.data = [];
            mu = randi([-10 10],1,nfeatures);
            sigma = eye(nfeatures);
            testCase.data.samples = mvnrnd(mu, sigma, nsamples);
            
            feature_labels = lattice_feature_labels([niterations norder nchannels nchannels]);
            feature_labels = reshape(feature_labels,1,numel(feature_labels));
            testCase.data.feature_labels = feature_labels;
            
            testCase.data.class_labels = [zeros(nsamples/2,1); ones(nsamples/2,1)];
        end
    end
    
    methods (Test)
        
        function test_stat_mean(testCase)
            plot_rc_feature_matrix(testCase.data,'mode','mean');
        end
        
        function test_stat_std(testCase)
            plot_rc_feature_matrix(testCase.data,'mode','std');
        end
        
        function test_stat_mean_diff(testCase)
            plot_rc_feature_matrix(testCase.data,'mode','mean-diff');
        end
        
        function test_boxplot(testCase)
            plot_rc_feature_matrix(testCase.data,'mode','boxplot','interactive',false);
        end
    end
    
end