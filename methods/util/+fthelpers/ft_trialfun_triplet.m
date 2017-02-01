function [trl,event] = ft_trialfun_triplet(cfg)
% selects the events in between two events
%
%   fields required in config
%   cfg.trialmid
%       describes middle event
%   cfg.trialmid.eventtype
%   cfg.trialmid.eventvalue
%   cfg.trialmid.prestim
%   cfg.trialmid.poststim
%
%   cfg.trialpre
%       describes preceeding event
%   cfg.trialpre.eventtype
%   cfg.trialpre.eventvalue
%
%   cfg.trialpost
%       describes following event
%   cfg.trialpost.eventtype
%   cfg.trialpost.eventvalue

if ~isfield(cfg,'dataset') || isempty(cfg.dataset)
    error('MATLAB:nonExistentField','missing dataset');
end

% check eventvalue
fields = {'trialmid','trialpre','trialpost'};
for i=1:length(fields)
    if ~isfield(cfg,fields{i})
        error('missing field %s',fields{i});
    end
    
    if ~ischar(cfg.(fields{i}).eventtype)
        error([mfilename ':input'],...
                '%s definition can only contain one event type',fields{i});
    end
    
    if isnumeric(cfg.(fields{i}).eventvalue)
        if length(cfg.(fields{i}).eventvalue) ~= 1
            error([mfilename ':input'],...
                '%s definition can only contain one event value',fields{i});
        end
%    elseif ischar(cfg.(fields{i}).eventvalue)
%        cfg.(fields{i}).eventvalue = {cfg.(fields{i}).eventvalue};
    else
        errorr([mfilename ':input'],...
            '%s definition can only contain one event value',fields{i});
    end
end

if ~isfield(cfg.trialmid,'prestim')
    error('missing prestim');
end
if ~isfield(cfg.trialmid,'poststim')
    error('missing poststim');
end

%% the first part is common to all trial functions
% read the header (needed for the samping rate) and the events
hdr = ft_read_header(cfg.dataset);
event  = ft_read_event(cfg.dataset);

%% from here on it becomes specific to the experiment and the data format
% for the events of interest, find the sample numbers (these are integers)
% for the events of interest, find the trigger values (these are strings in the case of BrainVision)
% EVsample   = [event.sample]';
EVvalue    = {event.value}';
EVtype     = {event.type}';

% select potential pre events of same type
pre_event_type = find(strcmp(cfg.trialpre.eventtype, EVtype)==1);
pre_event_value = find(strcmp(cfg.trialpre.eventvalue, EVvalue)==1);
pre_event = intersect(pre_event_type,pre_event_value); % indices

% select potential mid events
mid_event_type = find(strcmp(cfg.trialmid.eventtype, EVtype)==1);
mid_event_value = find(strcmp(cfg.trialmid.eventvalue, EVvalue)==1);
mid_event = intersect(mid_event_type,mid_event_value); % indices

% select potential post events
post_event_type = find(strcmp(cfg.trialpost.eventtype, EVtype)==1);
post_event_value = find(strcmp(cfg.trialpost.eventvalue, EVvalue)==1);
post_event = intersect(post_event_type,post_event_value); % indices

% select mid events where the pre event matches
pre_check = intersect(pre_event+1,mid_event);
% select mid events where the post event matches
pre_post_check = intersect(pre_check,post_event-1);

% select samples
EVsample = [event(pre_post_check).sample]';

trloff = round(-cfg.trialmid.prestim * hdr.Fs);
trloff = repmat(trloff,length(pre_post_check),1);
trldur = round((cfg.trialmid.prestim + cfg.trialmid.poststim)*hdr.Fs) - 1;
trlbeg = EVsample + trloff;
trlend = trlbeg + trldur;

%% the last part is again common to all trial functions
% return the trl matrix (required)
trl = [trlbeg trlend trloff];

end