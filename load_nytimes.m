function [datatable] = load_nytimes

% load jhu data

% get a time stamp and create a directory to save the graphs
currTime = clock;

% load the csv data from the nytimes repository
csvstring = urlread('https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv');
fid = fopen('tempdata.csv','w');
fprintf(fid,'%s',csvstring);
fclose(fid);
datatable = readtable('tempdata.csv');
delete('tempdata.csv')