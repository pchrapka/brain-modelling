function HMicbm152_dipoli_cm()
% HMicbm152_dipoli_cm

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

[data_dir,~,~] = fileparts(which('create_icbm152'));

cfg = [];
cfg.load_files = {...
    {'mri_headmodel', fullfile(data_dir,'icbm152_bem.mat')},...
    };


save(fullfile(srcdir, [strrep(mfilename,'_','-') '.mat']),'cfg');

end