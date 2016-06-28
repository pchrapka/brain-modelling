classdef LatticeTrace < handle
    %LatticeStats Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
    end
    
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
                    case 'A'
                        obj.trace.A(iter,:,:,:) = obj.filter.A;
                    case 'ferror'
                        obj.trace.ferror(iter,:,:) = obj.filter.ferror;
                    case 'x'
                        obj.trace.x(iter,:,:,:) = obj.filter.x;
                    otherwise
                        error('unknown field name %s',field);
                end
            end
        end
        
        function plot_trace(obj,iter,varargin)
            %
            %   Parameters
            %   ----------
            %   ch1 (integer, default = 1)
            %       channel 1 selection
            %   ch2 (integer, default = 1)
            %       channel 2 selection
            %   true (matrix)
            %       true value of Kf [order samples]
            %   title (string)
            %       plot title
            %   fields (cell array, default = {'Kf'})
            %       traces to include in plot
            %   mode (string, default = 'subplot')
            %       plotting mode: subplot, 3d, grid
            
            
            p = inputParser();
            addParameter(p,'ch1',1,@isnumeric);
            addParameter(p,'ch2',1,@isnumeric);
            addParameter(p,'true',[]);
            addParameter(p,'title',obj.filter.name,@ischar);
            addParameter(p,'fields',{'Kf'},@iscell);
            params_mode = {'subplot','3d','grid'};
            addParameter(p,'mode','subplot',@(x) any(validatestring(x,params_mode)));
            parse(p,varargin{:});
            
            % clear the figure;
            %clf;
            
            norder = obj.filter.order;
            rows = norder;
            cols = 1;
            switch p.Results.mode
                case 'subplot'
                    for k=1:norder
                        z = [];
                        legend_str = {};
                        
                        subaxis(rows, cols, k,...
                            'Spacing', 0, 'SpacingVert', 0, 'Padding', 0, 'Margin', 0.1);
                        
                        % plot true value
                        if ~isempty(p.Results.true)
                            z(end+1) = plot(1:iter, p.Results.true(1:iter,k,p.Results.ch1,p.Results.ch2));
                            legend_str{end+1} = 'True';
                            hold on;
                        end
                        
                        % plot estimate
                        nfields = length(p.Results.fields);
                        for j=1:nfields
                            z(end+1) = obj.plot_field(p.Results.fields{j},iter,k,p.Results);
                            legend_str{end+1} = obj.filter.name;
                            hold on;
                        end
                        
                        xlim([1 max(iter,2)]);
                        ylim([-1 1]);
                        
                        if k == 1
                            title(p.Results.title);
                        end
                        
                        if k == norder
                            % plot small error indicators
                            errors_ind = -1*[obj.errors(1:iter).warning];
                            errors_ind(errors_ind == 0) = NaN;
                            hold on;
                            plot(1:iter, errors_ind, 'o');
                            
                            %legend(z,legend_str,'Location','SouthWest');
                            % NOTE legend consideraly slows down plotting
                        else
                            set(gca,'XTickLabel',[]);
                        end
                        hold off;
                    end
                    
                case '3d'
                    z = [];
                    legend_str = {};
                    hold on;
                    
                    colors = {'b','r','g','m','k'};
                    alpha_val = 0.2;
                    count = 1;
                        
                    % plot true value
                    if ~isempty(p.Results.true)
                        data = squeeze(p.Results.true(iter,:,:,:));
                        nparams = numel(data);
                        data = reshape(shiftdim(data,2),1,nparams);
                        z(count) = plot3(repmat(iter,nparams,1), 1:nparams, data, colors{count});
                        z_color = get(z(count),'Color');
                        set(z(count),'Color',[z_color alpha_val]);
                        legend_str{count} = 'True';
                        count = count + 1;
                        hold on;
                    end
                    
                    % plot estimate
                    nfields = length(p.Results.fields);
                    for j=1:nfields
                        data_field = obj.trace.(p.Results.fields{j});
                        data = squeeze(data_field(iter,:,:,:));
                        nparams = numel(data);
                        data = reshape(shiftdim(data,2),1,nparams);
                        z(count) = plot3(repmat(iter,nparams,1), 1:nparams, data, colors{count});
                        %z_color = get(z(count),'Color');
                        %set(z(count),'Color',[z_color alpha_val]);
                        legend_str{count} = obj.filter.name;
                        count = count + 1;
                        hold on;
                    end
                    
                    xlim([1 max(iter,2)]);
                    zlim([-1 1]);
                    
                    title(p.Results.title);
                    
                    view(3);
                    hold off;
                    
                case 'grid'
                    nfields = length(p.Results.fields);
                    if nfields > 1
                        error('not sure what to do with multiple fields');
                    end
                    
                    clim = [-1 1];
                    
                    nrows = obj.filter.order;
                    ncols = 2;
                    for i=1:nrows
                        idx_plot = (i-1)*ncols + 1;
                        
                        subplot(nrows,ncols,idx_plot);
                        data = obj.trace.(p.Results.fields{1});
                        imagesc(squeeze(data(iter,i,:,:)),clim);
                        set(gca,'XTickLabel',[]);
                        set(gca,'YTickLabel',[]);
                        ylabel(sprintf('%d',i));
                        
                        if i==1
                            title({obj.filter.name,p.Results.fields{1}});
                        end
                        
                        subplot(nrows,ncols,idx_plot+1);
                        data = squeeze(p.Results.true(iter,i,:,:));
                        imagesc(squeeze(data),clim);
                        set(gca,'XTickLabel',[]);
                        set(gca,'YTickLabel',[]);
                        
                        if i==1
                            title({'True',p.Results.fields{1}});
                        end
                        
                        if i==nrows
                            colorbar;
                        end
                    end
                    
                otherwise
                    error('unknown plotting mode');
            end
        end
        
        function run(obj,samples,varargin)
            %   Input
            %   -----
            %   samples (matrix)
            %       sample data. the data can be specified as 
            %       [channels samples] or [channels samples trials]
            %
            %   Parameters
            %   ----------
            %   mode (default = 'none')
            %       runtime options: 'none','plot'
            %   plot_options (cell array)
            %       name, value list of plot options, see
            %       LatticeTrace.plot_trace
            %   verbosity (default = 0)
            %       selects chattiness of code, options: 0,1,2
            
            p = inputParser();
            addRequired(p,'samples');
            addParameter(p,'mode','none',...
                @(x) any(validatestring(x,{'none','plot'})));
            addParameter(p,'verbosity',0,@isnumeric);
            addParameter(p,'plot_options',{},@iscell);
            parse(p,samples,varargin{:});
            
            % get size
            nsamples = size(samples,2);
            
            % init the trace
            obj.trace_init(nsamples);
            
            % init error
            obj.errors(1:nsamples) = obj.errors(1);
            
            if p.Results.verbosity > 0
                fprintf('starting: %s\n',obj.filter.name);
            end
            pause(1);

            % compute reflection coef estimates
            for i=1:nsamples
                
                if p.Results.verbosity > 1
                    fprintf('sample %d\n',i);
                end
                
                % clear the last warning
                lastwarn('');
                
                % update the filter with the new measurement
                obj.filter.update(permute(samples(:,i,:),[1 3 2]),...
                    'verbosity',p.Results.verbosity);
                
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
                
                if isequal(p.Results.mode,'plot')
                    obj.plot_trace(i,p.Results.plot_options{:});
                    drawnow;
                    %pause(0.005);
                end
                
            end
            
        end
    end
    
    methods (Access = protected)
        function out = plot_field(obj,field,iter,order,params)
            switch field
                case 'Kf'
                    out = plot(1:iter, obj.trace.Kf(1:iter,order,params.ch1,params.ch2));
                case 'Kb'
                    out = plot(1:iter, obj.trace.Kb(1:iter,order,params.ch1,params.ch2));
                case 'A'
                    out = plot(1:iter, obj.trace.A(1:iter,order,params.ch1,params.ch2));
                case 'x'
                    out = plot(1:iter, obj.trace.x(1:iter,order));
            end
        end
    end
    
end

