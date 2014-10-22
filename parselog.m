function data = parselog(logfile)
% PARSELOG parse Philips MRI (R3) log file
%
% data.seriesNo - series number
%     .date     - date string
%     .time     - scan event time strings
%     .duration - scan event durations, in seconds
%     .pars     - preparation parameters

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
              'actgain',0,...
              'turbo',turbo);
data = struct('seriesNo',0,...
              'date','0000-00-00',...
              'time',time,...
              'duration',[],...
              'pars',pars);

%% regular expressions
exp.gain = 'ain set to \(flt\): (?<gain>[.0-9]+)';
exp.cor  = 'updating `PR_RG_turbo_(?<cor>\w+)\[\s+(?<slice>\d+)\s\] from 0 to (?<value>[-0-9]+)';
exp.prepstart =   ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*SingleScan ChangesState from Dispatched to Preparing.  SingleScanJobID: (?<seriesNo>\d+)';
exp.rgprepstart = ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*RG: Receive gain optimization';
exp.rgprepend =   ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*FRC: Receiver correction';
exp.scanstart =   ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*CDAS\W+Scan starts';
exp.scanend  =    ']\W+(?<date>\w[-0-9]+)\W+(?<time>\d[:.0-9]+)[\s\S]*Scan progress msg -> SCANEXEC, 100%';

%% parse log
fid = fopen(logfile);
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    out = regexp(tline,exp.gain,'names');
    if ~isempty(out)
        data.pars.gain = str2num(out.gain);
        continue
    end
    out = regexp(tline,exp.cor,'names');
    if ~isempty(out)
        data.pars.turbo(str2num(out.slice)+1).(out.cor) = str2num(out.value);
        clear out
        continue
    end
    out = regexp(tline,exp.prepstart,'names');
    if ~isempty(out)
        data.seriesNo = out.seriesNo;
        data.date = out.date;
        data.time.prepstart = out.time;
        clear out
        continue
    end
    out = regexp(tline,exp.rgprepstart,'names');
    if ~isempty(out)
        data.time.rgprepstart = out.time;
        clear out
        continue
    end
    out = regexp(tline,exp.rgprepend,'names');
    if ~isempty(out)
        data.time.rgprepend = out.time;
        clear out
        continue
    end
    out = regexp(tline,exp.scanstart,'names');
    if ~isempty(out)
        data.time.scanstart = out.time;
        clear out
        continue
    end
    out = regexp(tline,exp.scanend,'names');
    if ~isempty(out)
        data.time.scanend = out.time;
        clear out
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