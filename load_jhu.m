function [datatable,allDate] = load_jhu

% load jhu data

% get a time stamp and create a directory to save the graphs
currTime = clock;
% saveFolder = sprintf('%d_%02d_%02d county jhu',...
%     currTime(1),currTime(2),currTime(3));
% if ~exist(saveFolder,'dir');mkdir(saveFolder);end

% load the csv data from the jhu repository and clean data
csvstring = urlread('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv');
fid = fopen('tempdata.csv','w');
fprintf(fid,'%s',csvstring);
fclose(fid);
opts = detectImportOptions('tempdata.csv'); % Initial detection
opts.VariableNamesLine = 1; % Set variable names line
opts.DataLine = [2];
datatable = readtable('tempdata.csv',opts);
fid = fopen('tempdata.csv','r');
varNamesStr = fgetl(fid);
fclose(fid);
varNamesCell = strsplit(varNamesStr,',');
cdate = 0;
for kvar = 1:numel(varNamesCell)
    if ~ismember(varNamesCell{kvar}(1),...
            {'1','2','3','4','5','6','7','8','9','0'})
        datatable.Properties.VariableNames{kvar} = varNamesCell{kvar};
    else
        cdate = cdate+1;
        thisVarName = varNamesCell{kvar};
        thisVarName(strfind(thisVarName,'/')) = '_';
        datatable.Properties.VariableNames{kvar} = ['date_',thisVarName];
        allDate(cdate) = datetime(thisVarName,'InputFormat','MM_dd_yy');
    end
end
delete('tempdata.csv')