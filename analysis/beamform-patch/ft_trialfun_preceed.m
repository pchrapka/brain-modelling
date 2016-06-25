function [trl,event] = ft_trialfun_preceed(cfg)

if ~isfield(cfg,'dataset') || isempty(cfg.dataset)
    error('MATLAB:nonExistentField','missing dataset');
end

if ~ischar(cfg.trialdef.eventvalue)
    error([mfilename ':trialdef'],...
        'trialdef definition can only contain one event value');
end

if ~ischar(cfg.trialpost.eventvalue)
    error([mfilename ':trialpost'],...
        'trialpost definition can only contain one event value');
end

if ~iscell(cfg.trialdef.eventvalue)
    cfg.trialdef.eventvalue = {cfg.trialdef.eventvalue};
end

%% the first part is common to all trial functions
% read the header (needed for the samping rate) and the events
hdr = ft_read_header(cfg.dataset);
event  = ft_read_event(cfg.dataset);

%% from here on it becomes specific to the experiment and the data format
% for the events of interest, find the sample numbers (these are integers)
% for the events of interest, find the trigger values (these are strings in the case of BrainVision)
% EVsample   = [event.sample]';
% EVvalue    = {event.value}';
EVtype     = {event.type}';

% select potential pre events of same type
pre_event_type = find(strcmp(cfg.trialdef.eventtype, EVtype)==1);
EVsample = [event(pre_event_type).sample]';
EVvalue = {event(pre_event_type).value}';

% select the post events
% post_event_type = find(strcmp(cfg.trialpost.eventtype, EVtype)==1);
post_event_value = find(strcmp(cfg.trialpost.eventvalue, EVvalue)==1);
% post_event = intersect(post_event_type, post_event_value);
post_event = post_event_value;

% for each post event find the stimulus immediately preceeding it
pre_event_temp = zeros(size(post_event));
for w = 1:length(post_event)
    pre_event_idx = post_event(w) - 1;
    if pre_event_idx > 0
        if strcmp(cfg.trialdef.eventvalue, EVvalue{pre_event_idx}) == 1
            pre_event_temp(w) = pre_event_idx;
        end
    end
end

pre_event = pre_event_temp(pre_event_temp > 0);

PreTrig   = round(cfg.trialdef.prestim * hdr.Fs);
PostTrig  = round(cfg.trialdef.poststim * hdr.Fs);

begsample = EVsample(pre_event) - PreTrig;
endsample = EVsample(pre_event) + PostTrig;

offset = -PreTrig*ones(size(endsample));

%% the last part is again common to all trial functions
% return the trl matrix (required)
trl = [begsample endsample offset];

end