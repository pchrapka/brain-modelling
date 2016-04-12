classdef LatticeTrace < handle
    %LatticeStats Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        % lattice filter object
        filter;
        
        % runtime errors
        errors;
        
        % trace
        trace;
        
        % relative error variace
        rev;
    end
    
    properties (Access = protected)
        % fields to track
        fields;
    end
    
    methods
        function obj = LatticeTrace(filter,varargin)
            %
            p = inputParser();
            addRequired(p,'filter');
            addParameter(p,'fields',{'Kf','Kb'},@iscell);
            parse(p,filter,varargin{:});
            
            obj.filter = p.Results.filter;
            obj.fields = p.Results.fields;
            obj.errors = struct('warning',false,'id','','msg','');
            
            % init traces
            nfields = length(obj.fields);
            for i=1:nfields
                field = obj.fields{i};
                fieldsize = size(obj.filter.(field));
                obj.trace.(field) = zeros(fieldsize);
            end
        end
        
        function obj = trace_init(obj,nsamples)
            %TRACE_INIT initializes the trace
            %   TRACE_INIT(obj,nsamples) initializes the trace
            %
            %   Input
            %   -----
            %   nsamples (integer)
            %       number of iterations 
            
            % init trace by number of samples
            nfields = length(obj.fields);
            for i=1:nfields
                field = obj.fields{i};
                fieldsize = size(obj.filter.(field));
                obj.trace.(field) = zeros([nsamples fieldsize]);
            end
        end
        
        function obj = trace_copy(obj,iter)
            %TRACE_COPY copies data from current filter iteration
            %   TRACE_COPY(obj,iter) copies data from current filter
            %   iteration
            
            nfields = length(obj.fields);
            for i=1:nfields
                field = obj.fields{i};
                switch field
                    case 'Kf'
                        obj.trace.Kf(iter,:,:,:) = obj.filter.Kf;
                    case 'Kb'
                        obj.trace.Kb(iter,:,:,:) = obj.filter.Kb;
                    case 'ferror'
                        obj.trace.ferror(iter,:,:) = obj.filter.ferror;
                    otherwise
                        error('unknown field name %s',field);
                end
            end
        end
        
        function run(obj,samples,varargin)
            %   samples (matrix)
            %       sample matrix [channels samples]
            %
            %   Parameters
            %   ----------
            %   verbosity (default = 0)
            %       selects chattiness of code, options: 0,1,2
            
            p = inputParser();
            addRequired(p,'samples',@ismatrix);
            addParameter(p,'verbosity',0,@isnumeric);
            parse(p,samples,varargin{:});
            
            % get size
            nsamples = size(samples,2);
            
            % init the trace
            obj.trace_init(nsamples);
            
            % init error
            obj.errors(1:nsamples) = obj.errors(1);

            % compute reflection coef estimates
            for i=1:nsamples
                if p.Results.verbosity > 1
                    fprintf('sample %d\n',i);
                end
                
                % clear the last warning
                lastwarn('');
                
                % update the filter with the new measurement
                obj.filter.update(samples(:,i));
                
                % check last warning
                [msg, lastid] = lastwarn();
                if ~isempty(msg)
                    %if isequal(lastid,'MATLAB:singularMatrix')
                    obj.errors(i).warning = true;
                    obj.errors(i).msg = msg;
                    obj.errors(i).id = lastid;
                end
                
                % copy filter state
                obj.trace_copy(i);
            end
            
            % compute relative error variance
            % FIXME how do i do this?
%             msy = var(samples,1);
%             obj.rev = mse./msy;
        end
    end
    
end

