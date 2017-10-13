%% run_bf_patch_beta

%% standard trials
pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(6,10,'std')); 
pipeline.process();

%% visual checks

do_plots = true;

if do_plots
    obj_elec = pipeline.steps{end}.get_dep('ftb.Electrodes');
    
    % electrodes pre-alignment
    figure;
    obj_elec.plot({'fiducials','scalp','electrodes','electrodes-labels'});
    
    % electrodes post-alignment
    figure;
    obj_elec.plot({'fiducials','scalp','electrodes-aligned','electrodes-labels'});
end

%% deviant trials
% pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(6,10,'odd'));
% pipeline.process();
