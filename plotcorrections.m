function varargout = plotcorrections(mc_cor_full,rfex_phase_cor_full,seriesname_full,mc_cor_rrg,rfex_phase_cor_rrg,seriesname_rrg,figfile)
% PLOTCORRECTIONS plot turbo spin echo correction values
% 
% data - structure of series info produced by parselog()
%

linecolors_mc_cor = {[0.3 0.3 0.3]; ...
                     [1.0 0.3 0.3];};
linecolors_rp_cor = {[0.3 0.3 0.3]; ...
                     [0.3 0.3 1.0];};

seriesnames = {strrep(seriesname_full,'_','\_'), strrep(seriesname_rrg,'_','\_')};

maxslice = max(length(mc_cor_full),length(mc_cor_rrg));
                 
h1 = figure;
hold on
plot(0:499,zeros(1,500),'Color',[.6 .6 .6],'LineWidth',0.5)
p1{1} = plot(1:length(mc_cor_full),mc_cor_full,'Color',linecolors_mc_cor{1});
p1{2} = plot(1:length(mc_cor_rrg),mc_cor_rrg,'Color',linecolors_mc_cor{2});
xlabel('slice')
ylabel('mc\_cor (0.01 samples)')
axis([1 maxslice -15 15])
legend([p1{1},p1{2}],seriesnames)
legend('boxoff')

h2 = figure;
hold on
plot(0:499,zeros(1,500),'Color',[.6 .6 .6],'LineWidth',0.5)
p2{1} = plot(1:length(rfex_phase_cor_full),rfex_phase_cor_full,'Color',linecolors_rp_cor{1});
p2{2} = plot(1:length(rfex_phase_cor_rrg),rfex_phase_cor_rrg,'Color',linecolors_rp_cor{2});
xlabel('slice')
ylabel('rfex\_phase\_cor (0.0055 degrees)')
axis([1 maxslice -1500 1500])
legend([p2{1},p2{2}],seriesnames)
legend('boxoff')

if (exist('figfile','var'))
    [path,file,ext] = fileparts(figfile);
    figname_mc_cor = fullfile(path,[file '-mc_cor' ext]);
    saveas(h1,figname_mc_cor);
    close(h1)
    figname_rp_cor = fullfile(path,[file '-rfex_phase_cor' ext]);
    saveas(h2,figname_rp_cor);
    close(h2)
else
    varargout{1} = h1;
    varargout{2} = h2;
end

end  % plotcorrections()