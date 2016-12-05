classdef (Abstract) VARProcess < handle
    %VARProcess Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
    end
    
    properties(Abstract, SetAccess = private)
        init;
    end
    
    methods (Abstract)
        coefs_set(obj);
        %COEFS_SET sets coefficients of VAR process
        coefs_gen(obj);
        %COEFS_GEN generates coefficients of VAR process

        coefs_gen_sparse(obj, varargin)
        %COEFS_GEN_SPARSE generates coefficients of VAR process
        
        stable = coefs_stable(obj,verbose)
        %COEFS_STABLE checks VAR coefficients for stability
            
        F = coefs_getF(obj)
        %COEFS_GETF(OBJ) builds matrix F as defined by Hamilton (10.1.10)
        
        [Y,Y_norm, noise] = simulate(obj, nsamples, varargin)
        %SIMULATE simulate VAR process
        
        coefs_time = get_coefs_vs_time(obj, nsamples, coefs)
        %GET_COEFS_VS_TIME returns the coefficients over time
        
    end
            
    
end

