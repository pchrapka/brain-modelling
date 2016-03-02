function [pipeline] = add_jobs(pipeline, job)
%ADD_JOBS adds jobs to the pipeline
%
%   ADD_JOBS(PIPELINE, JOB)
%
%   pipeline
%       pipeline struct
%   job
%       struct array of jobs to be added each with the following fields
%           name (string)
%           brick (string)
%           in (struct)
%           out (struct)
%           opt (struct)
%

for k=1:length(job)
    pipeline = psom_add_job(pipeline,...
        job(k).name, job(k).brick, job(k).in, job(k).out, job(k).opt);
end

end