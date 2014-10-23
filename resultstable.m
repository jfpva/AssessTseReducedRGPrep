function mdtable = resultstable(data)
% RESULTSTABLE print results in table
% 
% data - structure of series info produced by parselog()
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

%% Setup

addstr = @(str1,str2)sprintf('%s\n%s',str1,str2);

%% Make table

mdtable = '';
mdtable = addstr(mdtable,...
    sprintf('%-10s | %-20s | %-17s | %-21s | %-17s | %-19s','Series No.','Series Name','Gain Atten''n (dB)','Non-RG Prep Dur''n (s)','RG Prep Dur''n (s)','Scan Dyn. Dur''n (s)'));
mdtable = addstr(mdtable,...
    strrep(sprintf('%0-10s | %0-20s | %0-17s | %0-21s | %0-17s | %0-19s','','','','','',''),'0','-'));
for iD = 1:length(data),
    D = data(iD);
    mdtable = addstr(mdtable,...
        sprintf('%-10i | %-20s | %-17.4f | %-21.2f | %-17.2f | %-19.2f',D.seriesNo,D.seriesName,D.pars.gain,D.duration.notrgprep,D.duration.rgprep,D.duration.scan));
end

end