function rc2pdc(files_in,files_out,opt)
%RC2PDC convert reflection coefficients to PDC
%   RC2PDC convert reflection coefficients to PDC
%
%   Input
%   -----
%   files_in (string/cell)
%       file name(s) of samples file(s) to process, see output of
%       bricks.lattice_filter_sources
%   files_out (string)
%       output file name
%   opt (cell array)
%       function options specified as name value pairs
%
%   Output
%   ------
%   output data contains the following fields
%   
%   data ?
%   

p = inputParser;
p.KeepUnmatched = true;
p.StructExpand = false;
addRequired(p,'files_in',@(x) ischar(x) | isstruct(x) | iscell(x));
addRequired(p,'files_out',@ischar);
parse(p,files_in,files_out,opt{:});

end