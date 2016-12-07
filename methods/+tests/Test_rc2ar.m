classdef Test_rc2ar < matlab.unittest.TestCase
    %TestVAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    properties (TestParameter)
    end
    
    methods (TestClassSetup)
    end
    
    methods (TestClassTeardown)
    end
    
    methods (Test)
        function test_rc2ar(testCase)
            nchannels = 4;
            norder = 10;
            order_est = norder;
            lambda = 0.99;
            
            nsamples = 2000;
            ntrials = 1;
            
            nsims = 1;
            nsims_generate = 2;
            
            %% set up vrc
            stable = false;
            while ~stable
                vrc_process = VRC(nchannels,norder);
                vrc_process.coefs_gen_sparse('structure','fullchannels',...
                    'ncouplings',3,'mode','exact','stable',true,'ncoefs',8);
                
                kf_true = vrc_process.Kf;
                kb_true = vrc_process.Kb;
                
                [A,Ab] = rc2ar(kf_true,kb_true);
                
                % check ar by setting up var process
                var = VAR(nchannels,order_est);
                var.coefs_set(rcarrayformat(A,'format',3));
                if var.coefs_stable()
                    stable = true;
                    fprintf('found coefficients\n');
                else
                    fprintf('unstable, searching...\n');
                end
            end
            
            data_var = [];
            for j=1:nsims_generate*ntrials
                [signal, signal_norm,~] = var.simulate(nsamples);
                data_var.signal(:,:,j) = signal;
                data_var.signal_norm(:,:,j) = signal_norm;
            end
            
            % filter VAR process, using an RC method
            %filter_check = MQRDLSL3(nchannels,order_est,lambda);
            filter_check = BurgVector(nchannels,order_est);
            trace_check = LatticeTrace(filter_check,'fields',{'Kf','Kb'});
            
            % warmup
            noise = gen_noise(nchannels, nsamples, ntrials);
            trace_check.warmup(noise);
            
            trace_check.warmup(data_var.signal(:,:,end));
            
            % filter it
            trace_check.run(data_var.signal(:,:,1:nsims));
            
            kf_check = squeeze(trace_check.trace.Kf(end,:,:,:));
            kb_check = squeeze(trace_check.trace.Kf(end,:,:,:));
            
            % checking against the original vrc process
            testCase.verifyEqual(kf_check, kf_true, 'AbsTol', 0.3);
            testCase.verifyEqual(kb_check, kb_true, 'AbsTol', 0.3);
        end
    end
end