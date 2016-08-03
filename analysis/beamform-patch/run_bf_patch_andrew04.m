%% run_bf_patch_andrew04

%% pipeline so far
pipeline = build_pipeline_beamformer('paramsbf_sd_andrew04');
pipeline.process();

%% visual checks

do_plots = true;

if do_plots
    % electrodes pre-alignment
    figure;
    obj_elec.plot({'fiducials','scalp','electrodes','electrodes-labels'});
    
    % electrodes post-alignment
    figure;
    obj_elec.plot({'fiducials','scalp','electrodes-aligned','electrodes-labels'});
end