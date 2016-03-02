function fb_make_configs()
%FB_MAKE_CONFIGS creates default AnalysisStep configs
%   FB_MAKE_CONFIGS creates default AnalysisStep configs

[srcdir,~,~] = fileparts(mfilename('fullpath'));

% get configs
files = dir(fullfile(srcdir,'configs','*.m'));
% compile mat files
for i=1:length(files)
    script = strrep(files(i).name, '.m', '');
    eval(script);
end

end