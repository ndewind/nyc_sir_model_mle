function [datatable] = load_nychealth_data
% load nyc dohmh data and save it to a local folder for permanent records


% get a time stamp and create a directory to save the graphs
savedir = fullfile(pwd,'nyc_dohmh_data');
if ~exist(savedir,'dir')
    mkdir(savedir)
end
currTime = clock;
saveFname = sprintf('nyc_dohmh_data %d_%02d_%02d.csv',...
    currTime(1),currTime(2),currTime(3));

% load the csv data from the jhu repository and clean data
% csvstring = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/probable-confirmed-dod.csv');
csvstring = urlread('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/deaths/probable-confirmed-dod.csv');
fid = fopen(fullfile(savedir,saveFname),'w');
fprintf(fid,'%s',csvstring);
fclose(fid);
opts = detectImportOptions(fullfile(savedir,saveFname)); % Initial detection
opts.VariableNamesLine = 1; % Set variable names line
opts.DataLine = [2];
datatable = readtable(fullfile(savedir,saveFname),opts);
% datatable.date_of_death = datatable.DATE_OF_DEATH + years(2000);
datatable.date_of_death = datatable.DATE_OF_DEATH;
datatable.PROBABLE_COUNT(isnan(datatable.PROBABLE_COUNT)) = 0;
datatable.CONFIRMED_COUNT(isnan(datatable.CONFIRMED_COUNT)) = 0;
