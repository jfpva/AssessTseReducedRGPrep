function example()


%% setup

% relevant directories
logdir = '~/path-to-experiment/log';
resultsdir = '~/path-to-experiment/results';
path_to_yaml_toolbox = '~/path-to-toolboxes/YAMLMatlab_0.4.3';

% initial paths
origpath = path;

% Add YAML toolbox
% https://code.google.com/p/yamlmatlab/
addpath(genpath(path_to_yaml_toolbox))

%% locate files

% input
logfile = { fullfile(logdir,'log_fl_20102014_1141570_10_2_drm1t2sagrrgprepsenseV4.log'); ...
            fullfile(logdir,'log_fl_20102014_1145220_11_2_drm1t2sagfullprepsenseV4.log'); ...
            fullfile(logdir,'log_fl_20102014_1154438_13_2_drm1t2corrrgprepsenseV4.log'); ...
            fullfile(logdir,'log_fl_20102014_1157558_14_2_drm1t2corfullprepsenseV4.log'); ...
            fullfile(logdir,'log_fl_20102014_1205247_15_2_drm1t2trafullprepsenseV4.log'); ...
            fullfile(logdir,'log_fl_20102014_1210512_16_2_drm1t2tranoprepsenseV4.log'); ...
            fullfile(logdir,'log_fl_20102014_1213439_17_2_drm1t2trarrgprepsenseV4.log') }; 

% output
datafile = fullfile(resultsdir,'log-data.yaml');
mdfile = fullfile(resultsdir,'results.md');
durationsfigfile = fullfile(resultsdir,'scan-durations.png');
correctionsfigfile = fullfile(resultsdir,'turbo-corrections.png');

%% parse logs

for ii = 1:length(logfile),
    data(ii) = parselog(logfile{ii});
end

%% save data

WriteYaml(datafile,data);

%% assemble table

mdtable = resultstable(data);

%% save table

fid = fopen(mdfile,'w');
fprintf(fid,mdtable);
fclose(fid);

%% plot durations

plotdurations(data,durationsfigfile)

%% plot turbo corrections

[pathstr,filestr,extstr] = fileparts(correctionsfigfile);
% sag
figname = fullfile(pathstr,[filestr '-sag' extstr]);
plotcorrections([data(2).pars.turbo.mc_cor],...
                [data(2).pars.turbo.rfex_phase_cor],...
                 data(2).seriesName,...
                [data(1).pars.turbo.mc_cor],...
                [data(1).pars.turbo.rfex_phase_cor],...
                 data(1).seriesName,...
                 figname);
% cor
figname = fullfile(pathstr,[filestr '-cor' extstr]);
plotcorrections([data(4).pars.turbo.mc_cor],...
                [data(4).pars.turbo.rfex_phase_cor],...
                 data(4).seriesName,...
                [data(3).pars.turbo.mc_cor],...
                [data(3).pars.turbo.rfex_phase_cor],...
                 data(3).seriesName,...
                 figname);
% tra
figname = fullfile(pathstr,[filestr '-tra' extstr]);
plotcorrections([data(5).pars.turbo.mc_cor],...
                [data(5).pars.turbo.rfex_phase_cor],...
                 data(5).seriesName,...
                [data(7).pars.turbo.mc_cor],...
                [data(7).pars.turbo.rfex_phase_cor],...
                 data(7).seriesName,...
                 figname);

%% cleanup 

% set back path
path(origpath)

end  % example()