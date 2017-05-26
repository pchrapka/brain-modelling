classdef PDCAnalysis < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        view;
        % what do i do with plots?
        % configure a few to make it easier?
        
        % data info
        % prepend? flipped data? or do i take care of that in the data
        % phase outside of this class
        
        % lattice filter options
        ntrials = 0;
        nchannels = 0;
        filter_name = 'MCMTLOCCD_TWL4';
        gamma = 0;
        lambda = 0;
        order = 0;
        warmup_noise = true;
        warmup_data = true;
        tracefields = {'Kf','Kb','Rf','ferror','berrord'};
        
        % pdc options
        downsample = 1;
        metric = 'euc';
        
        % tuning options
        tune_plot_gamma = false;
        tune_plot_lambda = false;
        tune_plot_order = false;
        tune_criteria_samples = [];
        
        % surrogate analysis options
        surrogate_null_mode = '';
        surrogate_nresamples = 0;
        surrogate_alpha = 0;
        
        % surrogate plot options
        %surrogate_threshold_mode = 'significance';
        
    end
    
    methods
        function obj = PDCAnalysis(data_file)
            % TODO set defaults
            % TODO what about a parameter list of inputs? or just let
            % whoever modify them as required using the properties
            % TODO sanity check data in data_file
            % TODO set up output dirs
            
            %view = ViewPDC(); % TODO create empty object
        end
        
        function pdc(obj)
            % compute pdc
        end
        
        function surrogate(obj)
            % do surrogate analysis
        end
        
        function tune(obj)
            % do tuning stuff
        end
    end
    
end

