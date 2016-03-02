function cfg = load_config(name)
%load_config loads a saved config

outfile = fullfile('.ftb', 'config', [name '.mat']);
if exist(outfile, 'file')
    cfg = ftb.util.loadvar(outfile);
else
    error(['fb:' mfilename],...
        '%s does not exist',outfile);
end

end