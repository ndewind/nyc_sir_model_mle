function [minthis] = sir_nyc_obj_wrapper_maxfree_apple_doh(x)
% this version only has 3 free paramters. i0, early trans, and late trans

% values for debugging
% x = [0.0007, 0.36, 0.008, sqrt(14), 1]

% free parameters
i0 = x(1);
transRate = x(2)^2;
transRateAppleScalar = x(3)^2;
ifr = x(4);
recovDay = x(5)^2;
lingerDays = (sin(x(6))*0.5+0.5) * 21;

% static parameters (globals)
% global recovDay
% global lingerDays
% global ifr
% recovDay = 14;
% lingerDays = 13;
% recovDay = 21;
% lingerDays = 13-7;
% ifr = 0.01;

% fixed parameters
ndays = 90;
inter = 24;
nycpop = 8700000;

% load jhu data
load('dohdata','datatable')

% extract death data
thisCumDeath = cumsum(datatable.CONFIRMED_DEATHS+datatable.PROBABLE_DEATHS)...
    / nycpop;
thisDailyDeath = (datatable.CONFIRMED_DEATHS+datatable.PROBABLE_DEATHS)...
    / nycpop;
% firstDeathIndx = find(thisDailyDeath>0,1,'first');
allDate = datatable.DATE_OF_INTEREST;

% lockdown date for NYC
% realLockDownDay = datetime('3/22/2020','InputFormat','MM/dd/yyyy');
% lockdownDay = find(allDate == realLockDownDay)-1;

% apple movement data
opts = detectImportOptions('applemobilitytrends-2020-04-21.csv');
opts.VariableNamesLine = 1; opts.DataLine = 2;
appleData = readtable('applemobilitytrends-2020-04-21.csv',opts);
nycindx = find(strcmp(appleData.Var2,'New York City'));
appleDates = ( datetime('Jan/13/2020'):...
    datetime('Jan/13/2020')+days(size(appleData,2)-4) )';
appleMobile = mean(appleData{nycindx,4:end})'/100;
appleStartIndx = find(appleDates == allDate(1));
appleDates = appleDates(appleStartIndx:end);
appleMobile = appleMobile(appleStartIndx:end);
appleMobileEndMean = mean(appleMobile(end-6:end));
appleMobileHourInterp = interp1(1:numel(appleMobile),appleMobile,1:1/inter:numel(appleMobile))';
padSize = inter*ndays - numel(appleMobileHourInterp);
if sign(padSize)
appleMobileHourInterp = ...
    [appleMobileHourInterp;repmat(appleMobileEndMean,padSize+1,1)];
else
    appleMobileHourInterp = appleMobileHourInterp(1:end+padSize+1);
end

% calculate parameter predictions
[s,i,r,d,t] = calculate_SIRD_mobility(...
    i0,ifr,appleMobileHourInterp * transRateAppleScalar + transRate,...
    recovDay,ndays,inter);

% add death delay
d = [zeros(1,round(lingerDays*inter)),d(1:end-round(lingerDays*inter))];

% create hourly time axis with real date
realT = allDate(1) + t;

% compare model to NYC data
yhat = d(1:inter:numel(thisCumDeath)*inter)';
MSE = mean( (yhat-thisCumDeath).^2 );

% constrain with pregnancy study
studyTindx = realT > datetime('3/22/2020','InputFormat','MM/dd/yyyy') & ...
    realT < datetime('4/4/2020','InputFormat','MM/dd/yyyy');
MSEstudy = mean( (0.15 - mean(i(studyTindx))).^2 );

% constrain with state antibody study
studyTindx = realT > datetime('4/20/2020','InputFormat','MM/dd/yyyy') & ...
    realT < datetime('4/22/2020','InputFormat','MM/dd/yyyy');
MSEstudy2 = mean( (0.21 - mean(r(studyTindx))).^2 );

% objective function combines the two MSEs
% minthis = MSE/mean(thisCumDeath) + MSEstudy/0.15 + MSEstudy2/0.21;
minthis = MSE/mean(thisCumDeath) + MSEstudy2/0.21;
% minthis = MSE;
