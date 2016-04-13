function plot_svmmrmr_confusion(file_in)
%PLOT_SVMMRMR_CONFUSION plot confusion matrix for SVMMRMR output file
%   PLOT_SVMMRMR_CONFUSION plot confusion matrix for SVMMRMR output file
%   generate by bricks.features_validate
%
%   Input
%   -----
%   file_in (string)
%       name of data file

p = inputParser;
addRequired(p,'file_in',@ischar);
parse(p,file_in);

% load the data
data = ftb.util.loadvar(p.Results.file_in);

% plot confusion matrix
[confusion_mat, confusion_order] = confusionmat(data.class_labels, data.predictions);

heatmap(confusion_mat, confusion_order, confusion_order, 1,...
    'Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);

end
