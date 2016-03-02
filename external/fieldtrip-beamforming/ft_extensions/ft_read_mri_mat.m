function ft_read_mri_mat(cfg)
% ft_read_mri_mat reads anatomical and functional MRI data and saves it to
% a mat file. Just a wrapper around ft_read_mri that only uses inputfile
% and outputfile
%
%   To facilitate data-handling and distributed computing you can use
%     cfg.inputfile   =  ...
%     cfg.outputfile  =  ...
%   If you specify one of these (or both) the input data will be read from a *.mat file on disk and/or
%   the output data will be written to a *.mat file. These mat files should contain only a single
%   variable, corresponding with the input/output structure.

mri = ft_read_mri(cfg.inputfile);
save(cfg.outputfile, 'mri');

end