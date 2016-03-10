classdef DipoleSim < ftb.EEG
    %DipoleSim Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        % other properties see ftb.EEG
    end
    
    methods
        function obj = DipoleSim(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % use EEG constructor
            obj@ftb.EEG(params,name);
            obj.prefix = 'DS';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Leadfield'));
            parse(p,prev);
            
            % set the previous step, aka Leadfield
            obj.prev = p.Results.prev;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % get analysis step objects
            elecObj = obj.get_dep('ftb.Electrodes');
            hmObj = obj.get_dep('ftb.Headmodel');
            
            if obj.check_file(obj.preprocessed)
                % setup cfg
                cfgin = obj.config.ft_dipolesimulation;
                cfgin.elecfile = elecObj.elec_aligned;
                cfgin.headmodel = hmObj.mri_headmodel;
                
                % remove fiducial channels
                if ~isfield(cfgin, 'channel')
                    cfgin.channel = elecObj.remove_fiducials();
                    fprintf('%s: removing fiducial electrodes\n', mfilename)
                end
                
                % simulate dipoles
                data = ft_dipolesimulation(cfgin);
                save(obj.preprocessed, 'data');
            else
                fprintf('%s: skipping ft_dipolesimulation, already exists\n',...
                    mfilename);
            end
            
            if obj.check_file(obj.timelock)
                cfgin = obj.config.ft_timelockanalysis;
                cfgin.inputfile = obj.preprocessed;
                cfgin.outputfile = obj.timelock;
                
                ft_timelockanalysis(cfgin);
            else
                fprintf('%s: skipping ft_timelockanalysis, already exists\n',...
                    mfilename);
            end
            

        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'dipole'
            %       can also include elements from previous stages
            %       'leadfield'
            %       'electrodes'
            %       'electrodes-aligned'
            %       'electrodes-labels'
            %       'scalp'
            %       'skull'
            %       'brain'
            %       'fiducials'
            
            unit = 'mm';
            
            for i=1:length(elements)
                switch elements{i}
                    
                    case 'dipole'
                        hold on;
                        
                        component = 'signal';
                        
                        switch component
                            case 'signal'
                                color = 'blue';
                            case 'interference'
                                color = 'red';
                            otherwise
                        end
                        
                        params = obj.config.ft_dipolesimulation;
                        if isfield(params, 'dip')
                            dip = params.dip;
                            if ~isequal(dip.unit, unit)
                                switch dip.unit
                                    case 'cm'
                                        dip.pos = dip.pos*10;
                                    otherwise
                                        error(['ftb:' mfilename],...
                                            'implement unit %s', dip.unit);
                                end
                            end
                            ft_plot_dipole(dip.pos, dip.mom,...
                                ...'diameter',5,...
                                ...'length', 10,...
                                'color', color,...
                                'unit', unit);
                        end
                end
            end
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
        
        function plot_data(obj,mode)
            %   mode (string)
            %       selects data to plot: 'simulated', 'timelock'
            
            switch mode
                case 'timelock'
                    lfObj = obj.prev;
                    eObj = lfObj.prev;
                    %cfg.layout = ftb.util.loadvar(eObj.elec_aligned);
                    cfg.elecfile = eObj.elec_aligned;
                    layout = ft_prepare_layout(cfg,[]);
                    
                    data = ftb.util.loadvar(obj.timelock);
                    cfg = [];
                    %cfg.hlim = [0 1];
                    cfg.layout = layout;
                    cfg.showlabels = 'yes';
                    %ft_singleplotER(cfg, data);
                    ft_multiplotER(cfg, data);
                case 'simulated'
                    lfObj = obj.prev;
                    eObj = lfObj.prev;
                    %cfg.layout = ftb.util.loadvar(eObj.elec_aligned);
                    cfg.elecfile = eObj.elec_aligned;
                    layout = ft_prepare_layout(cfg,[]);
                    
                    data = ftb.util.loadvar(obj.simulated);
                    cfg = [];
                    %cfg.hlim = [0 1];
                    cfg.layout = layout;
                    cfg.showlabels = 'yes';
                    %ft_singleplotER(cfg, data);
                    ft_multiplotER(cfg, data);
                otherwise
                    error(['ftb:' mfilename],...
                        'unknown mode %s');
            end
        end
        
    end
end

