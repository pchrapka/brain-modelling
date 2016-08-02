function MRIicbm152()
% MRIicmb152

[srcdir,~,~] = fileparts(mfilename('fullpath'));

if ~exist('create_icbm152.m','file')
    fprintf('Download data-headmodel repo to folder containing\n');
    fprintf('Add data-headmodel/mni152 to path\n');
    fprintf('i.e.\n');
    fprintf('\tcd projects/\n');
    fprintf('\tgit clone https://github.com/pchrapka/data-headmodel.git\n');
    fprintf('\n\tin matlab:\n');
    fprintf('\taddpath(fullfile(''projects'',''data-headmodel'',''mni152''));\n');
    error('missing data-headmodel repo');
end

[mri_dir,~,~] = fileparts(which('create_icbm152'));

cfg = [];
cfg.load_files = {...
    {'mri_mat', fullfile(mri_dir,'icbm152_mri.mat')},...
    {'mri_segmented', fullfile(mri_dir,'icbm152_seg.mat')},...
    {'mri_mesh', 'MRIfake.mat'},...
    };

save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end