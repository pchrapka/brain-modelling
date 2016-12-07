function addParameter(varargin)
%addParameter fake shim function for pre-R2013b matlab

% NOTE verLessThan is very slow on many iterations

success = false;
% try finding the builtin matlab function first
c = which('addParameter','-all');
for i=1:length(c)
    result = strfind(c{i},['toolbox' filesep 'matlab']);
    if ~isempty(result)
        builtin(c{i},varargin{:});
        success = true;
    end
end

if ~success
    % if not, use addParamValue
    addParamValue(varargin{:});
end

end