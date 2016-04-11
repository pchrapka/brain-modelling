%% test_bricks_select_trials
% Note:
%   Uses data produced by exp10_beamform_patch

[srcdir,~,~] = fileparts(mfilename('fullpath'));

ntrials = 10;
files_in = {fullfile(srcdir,'../output-common/fb/MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/sourceanalysis.mat')};
files_out = cell(ntrials,1);
for i=1:ntrials
    files_out{i} = fullfile(srcdir,'output','test_bricks_select_trials',sprintf('trial%d.mat',i));
end
opt = {'trials', ntrials , 'labels', {'std'}};
bricks.select_trials(files_in,files_out,opt);