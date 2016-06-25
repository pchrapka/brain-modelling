%% exp10_beamform_patch

analysis = build_analysis_beamform_patch();

for i=1:length(analysis)
    analysis{i}.process();
end

%% Print beamformer output files
fprintf('Beamformer output:\n');
for i=1:length(analysis)
    fprintf('%s\n',analysis{i}.steps{end}.sourceanalysis);
end