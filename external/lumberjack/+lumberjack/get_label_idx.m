function [idx] = get_label_idx(labels, pattern)
%GET_LABEL_IDX returns the index of the label matching a pattern
%   GET_LABEL_IDX(LABELS, PATTERN) returns the index to a cell array of
%   LABELS that matches an exact PATTERN

% Translate the string to a pattern, escaping all sketchy characters
ptr =  regexptranslate('escape', pattern);
idx = find(~cellfun(@isempty,...
    regexp(labels, ['^' ptr '$'])));
end