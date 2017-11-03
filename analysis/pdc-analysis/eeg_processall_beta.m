function out = eeg_processall_beta(stimulus,subject,deviant_percent,patch_options)
% all eeg processing for Andrew's data, top level function 

%% output dir

params_data = DataBeta(subject,deviant_percent);

% dataset = data_file;
data_name2 = sprintf('%s-%s',stimulus,params_data.data_name);
comp_name = get_compname();
switch comp_name
    case {sprintf('Valentina\n')}
        analysis_dir = params_data.data_dir;
    otherwise
        analysis_dir = fullfile(get_project_dir(),'analysis','pdc-analysis');
end
outdir = fullfile(analysis_dir,'output',data_name2);

%% preprocess data for beamforming
eeg_preprocessing_beta(subject,deviant_percent,stimulus,...
    'outdir',outdir);

%% beamform sources
params_subject = paramsbf_sd_beta(...
    subject,deviant_percent,stimulus,patch_options{:});
pipedir = get_data_beta_pipedir();
pipeline = build_pipeline_beamformerpatch(params_subject,pipedir); 
pipeline.process();

%% compute induced sources
eeg_file = fullfile(outdir,'ft_rejectartifact.mat');
lf_file = pipeline.steps{end}.lf.leadfield;
sources_file = pipeline.steps{end}.sourceanalysis;

eeg_induced(sources_file, eeg_file, lf_file, 'outdir',outdir);

%% prep data for lattice filter

eeg_file = fullfile(outdir,'fthelpers.ft_phaselocked.mat');
% NOTE eeg_file needed only for fsample
[file_sources_info,file_sources] = eeg_prep_lattice_filter(...
    sources_file, eeg_file, lf_file, 'outdir', outdir, 'patch_type', params_subject.bf.patchmodel_name);

%% save outputs
out = [];
out.pipeline = pipeline;
out.outdir = outdir;
[out.outdir_sources,~,~] = fileparts(file_sources);
out.file_sources_info = file_sources_info;
out.file_sources = file_sources;

end
