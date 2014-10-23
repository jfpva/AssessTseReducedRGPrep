function varargout = plotdurations(data,figfile)
% PLOTDURATION generate figure showing durations of non-RG prep, RG prep, 
%   and scan
% 
% data - structure of series info produced by parselog()
%

nData = length(data);
for iD = 1:nData,
    seriesNames{iD} = sprintf('%2i %s',data(iD).seriesNo,strrep(data(iD).seriesName,'_','\_'));
    duration(:,iD) = [data(iD).duration.notrgprep; data(iD).duration.rgprep; data(iD).duration.scan];
end
h = figure;
barh(duration');
L = {'Non-RG Prep','RG Prep','Scan'};
legend(L,'Location','NorthEast')
legend('boxoff')
set(gca,'YTickLabel',seriesNames);
set(gca,'YDir','reverse');
xlabel('Duration (s)')
colormap(autumn)
if (exist('figfile','var'))
    saveas(h,figfile);
    close(h)
else
    varargout{1} = h;
end

end  % plotduration()