function data = parselog(logfile)
% PARSELOG parse Philips MRI (R3) log file
%
% logfile       - path to log file
% 
% data.seriesNo - series number
%     .date     - date string
%     .time     - scan event time strings
%     .duration - scan event durations, in seconds
%     .pars     - preparation parameters
% 

%% Info
% 
% Author(s)
%
% * Joshua van Amerom (jfpva)
%
% Repo
%
% * github.com/jfpva/AssessTseReducedRGPrep
% 

%% initialise output structure
defaultTime = '00:00:00.00';
time = struct('prepstart',defaultTime,...
              'rgprepstart',defaultTime,...
              'rgprepend',defaultTime,...
              'scanstart',defaultTime,...
              'scanend',defaultTime);
turbo = struct('mc_cor',0,...
              'rfex_phase_cor',0,...
              'el_cor',0);
pars = struct('gain',0,...
              'turbo',turbo);
data = struct('seriesName','',...
              'seriesNo',0,...
              'date','0000-00-00',...
              'time',time,...
              'duration',[],...
              'pars',pars);

%% regular expressions
exp.seriesName = '[\s\S]*scan_name\W+:\W+(?<seriesName>[\w|-]+)';
exp.gain = 'ain set to \(flt\): (?<gain>[.0-9]+)';
exp.cor  = 'updating `PR_RG_turbo_(?<cor>\w+)\[\s+(?<slice>\d+)\s\] from 0 to (?<value>[-0-9]+)';
exp.prepstart =   ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*SingleScan ChangesState from Dispatched to Preparing.  SingleScanJobID: (?<seriesNo>\d+)';
exp.rgprepstart = ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*Initial gain set to[\s\S]*';
exp.rgprepend =   ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*FRC: Receiver correction';
exp.scanstart =   ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*CDAS\W+Scan starts';
exp.scanend  =    ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*Scan progress msg -> SCANEXEC, 100%';

% NOTE: could add expressions for slice positions (e.g., 'Z Offcentre:')
% for alignment of series without common scan prescription 

%% parse log
fid = fopen(logfile);
while 1
    tline = fgetl(fid);
    if ~ischar(tline),
        break, 
    end
    clear out
    % Series name
    out = regexp(tline,exp.seriesName,'names');
    if ~isempty(out)
        data.seriesName = out.seriesName;
        continue
    end
    % Prep start
    out = regexp(tline,exp.prepstart,'names');
    if ~isempty(out)
        data.seriesNo = str2double(out.seriesNo);
        data.date = out.date;
        data.time.prepstart = out.time;
        continue
    end
    % RG prep start
    out = regexp(tline,exp.rgprepstart,'names');
    if ~isempty(out)
        data.time.rgprepstart = out.time;
        continue
    end
    % Gain
    out = regexp(tline,exp.gain,'names');
    if ~isempty(out)
        data.pars.gain = str2double(out.gain);
        continue
    end
    % Turbo corrections
    out = regexp(tline,exp.cor,'names');
    if ~isempty(out)
        data.pars.turbo(str2double(out.slice)+1).(out.cor) = str2double(out.value);
        continue
    end
    % RG prep end
    out = regexp(tline,exp.rgprepend,'names');
    if ~isempty(out)
        data.time.rgprepend = out.time;
        continue
    end
    % Scan start
    out = regexp(tline,exp.scanstart,'names');
    if ~isempty(out)
        data.time.scanstart = out.time;
        continue
    end
    % Scan end
    out = regexp(tline,exp.scanend,'names');
    if ~isempty(out)
        data.time.scanend = out.time;
        continue
    end
end
fclose(fid);

%% calculate durations
sec = @(t)60*60*str2double(t(1:2))+60*str2double(t(4:5))+str2double(t(7:end));
data.duration.prep = sec(data.time.scanstart) - sec(data.time.prepstart);
data.duration.rgprep = sec(data.time.rgprepend) - sec(data.time.rgprepstart);
data.duration.notrgprep = data.duration.prep - data.duration.rgprep;
data.duration.scan = sec(data.time.scanend) - sec(data.time.scanstart);

end  % parselog()