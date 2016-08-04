%% run_bf_patch_andrew

%% standard trials
% pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(4,10,'std'));
% % big forehead

% pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(2,10,'std')); 
% % big hair?

% pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(3,10,'std')); 
% % small back of head, but decent

% pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(5,10,'std')); 
% % better than 3

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(6,10,'std')); 
% % a bit large, would need a projection

% pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(8,10,'std')); 
% % shifted forward

% pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(10,10,'std')); 
% % extra side space

% so 3,5 or 6

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(6,10,'std')); 
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
% pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(6,10,'odd'));
% pipeline.process();