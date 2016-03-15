function [out] = copy_struct_fields(in, out)
%COPY_STRUCT_FIELDS copies fields from on struct to another
%   COPY_STRUCT_FIELDS(IN, OUT) copies fields from IN struct to OUT struct
%   and returns the updated OUT struct

% Add fields from in struct to out struct
fields = fieldnames(in);
for j=1:length(fields)
    field = fields{j};
    out.(field) = in.(field);
end
    
end