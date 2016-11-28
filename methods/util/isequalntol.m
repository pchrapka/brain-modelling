function result = isequalntol(testing,expecting,varargin)

p = inputParser();
addParameter(p,'AbsTol',[],@isnumeric);
addParameter(p,'Verbosity',false,@islogical);
parse(p,varargin{:});

result = true(size(testing));

if size(testing) ~= size(expecting)
    error('different sizes');
end

testing = testing(:);
expecting = expecting(:);
result = result(:);

for i=1:length(testing)
    
    if testing(i) < expecting(i) - p.Results.AbsTol || testing(i) > expecting(i) + p.Results.AbsTol
    	result(i) = false;
        if p.Results.Verbosity
            warning('expecting: %g\nactual: %g\n',expecting(i),testing(i));
        end
    end

end

end