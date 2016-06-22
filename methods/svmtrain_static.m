function [model,varargout] = svmtrain_static(samples,class_labels,varargin)
%SVMTRAIN_STATIC trains an SVM model
%   SVMTRAIN_STATIC(...) trains an SVM model
%
%   Parameters
%   ----------
%   implementation (string)
%       options are matlab or libsvm
%
%   matlab implementation
%   ---------------------
%   same parameters as fitcsvm, see fitcsvm
%
%   libsvm implementation
%   ---------------------
%   KernelFunction (string, default = 'rbf')
%   BoxConstraint (scalar, default = 0)
%   KernelScale (scalar, default = 1);
%
%   Output
%   ------
%   model
%       trained SVM model, empty when loss is requested as well
%   loss (scalar, optional)
%       cross validated loss of SVM
%

p = inputParser();
p.KeepUnmatched = true;
addRequired(p,'samples',@ismatrix);
addRequired(p,'class_labels',@isvector);
options_imp = {'matlab','libsvm'};
addParameter(p,'implementation','libsvm',@(x) any(validatestring(x,options_imp)));
parse(p,samples,class_labels,varargin{:});

flag_crossval = false;
if nargout > 1
    flag_crossval = true;
end

if isequal(p.Results.implementation,'matlab')
    model = fitcsvm(samples, class_labels, varargin{:});
    
    if flag_crossval
        % calculate the loss or CV error
        loss = kfoldLoss(model);
    end
else
    svm_params = [fieldnames(p.Unmatched) struct2cell(p.Unmatched)];
    svm_params = reshape(svm_params',1,numel(svm_params));
    
    p = inputParser();
    addParameter(p,'KernelFunction','rbf');
    addParameter(p,'BoxConstraint',0,@isnumeric);
    addParameter(p,'KernelScale',1,@isnumeric);
    params_verbosity = [0 1 2 3];
    addParameter(p,'verbosity',0,@(x) any(find(params_verbosity == x)));
    parse(p,svm_params{:});
    
    % set svm options
    % svm type
    svm_type = '-s 0 ';
    % kernel type
    switch p.Results.KernelFunction
        case 'rbf'
            kernel = '-t 2 ';
    end
    % kernel scale
    gamma = sprintf('-g %g ', p.Results.KernelScale);
    % cost constraint
    cost = sprintf('-c %g ', p.Results.BoxConstraint);
    if flag_crossval
        % n-fold cross validation mode
        crossval = sprintf('-v %d ', length(class_labels));
    end
    
    options = ['-q ' svm_type kernel gamma cost];
    if flag_crossval
        options = [options crossval];
    end
    
    if p.Results.verbosity > 2
        options = strrep(options,'-q ','');
    end
    
    if flag_crossval
        accuracy = svmtrain(class_labels, samples, options);
        loss = 100 - accuracy;
        model = [];
    else
        model = svmtrain(class_labels, samples, options);
    end
end

if nargout > 1
    varargout{1} = loss;
end

end