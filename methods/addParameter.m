function addParameter(varargin)
%addParameter fake shim function for pre-R2013b matlab

if verLessThan('matlab', '8.2.0.29') % R2013b
    addParamValue(varargin{:});
else
    builtin('addParameter',varargin{:});
end

end