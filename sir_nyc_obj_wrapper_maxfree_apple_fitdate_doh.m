function [minthis] = sir_nyc_obj_wrapper_maxfree_apple_fitdate_doh(x)
% this version only has 3 free paramters. i0, early trans, and late trans

% values for debugging
% x = [1, 0.16, 1, 0.008, sqrt(14), 1]

% free parameters
it0 = x(1)^2;
transRate = x(2)^2;
transRateAppleScalar = x(3)^2;
ifr = x(4);
recovDay = x(5)^2;
lingerDays = (sin(x(6))*0.5+0.5) * 21;

% static parameters
ndays = 180;
inter = 24;
nycpop = 8700000;
i0 = 100/nycpop;

% load dohmh data
load('dohdata','datatable')

% extract death data
thisCumDeath = cumsum(datatable.CONFIRMED_COUNT+datatable.PROBABLE_COUNT)...
    / nycpop;
thisDailyDeath = (datatable.CONFIRMED_COUNT+datatable.PROBABLE_COUNT)...
    / nycpop;
allDate = datatable.date_of_death;

% lockdown date for NYC (superceded by the apple mobility data estimate of
% lockdown efficacy)
% realLockDownDay = datetime('3/22/2020','InputFormat','MM/dd/yyyy');
% lockdownDay = find(allDate == realLockDownDay)-1;

% get current date
currTime = clock;

% apple movement data
appeDataFName = sprintf('applemobilitytrends-%d-%02d-%02d.csv',...
    currTime(1),currTime(2),currTime(3));
opts = detectImportOptions(appeDataFName);
opts.VariableNamesLine = 1; opts.DataLine = 2;
opts.VariableTypes(126:127) = {'double','double'};
appleData = readtable(appeDataFName,opts);
% special case of two missing columns 126 and 127 - set value to 125
appleData{:,126} = appleData{:,125};
appleData{:,127} = appleData{:,125};
nycindx = find(strcmp(appleData.Var2,'New York City') & ...
    strcmp(appleData.Var3,'transit') );
appleDates = ( datetime('Jan/13/2020'):...
    datetime('Jan/13/2020')+days(size(appleData,2)-6) )';
appleDates = [ (datetime('Jan/1/2020') + days(0:11))' ; appleDates];
appleMobile = mean(appleData{nycindx,7:end},1)'/100;
appleMobile = [ones(12,1);appleMobile];
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
[s,i,r,d,t] = calculate_SIRD_mobility_t0(...
    i0,it0,ifr,appleMobileHourInterp * transRateAppleScalar + transRate,...
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

% constrain with state antibody study (assume 24 days from symptoms to antibody)
studyTindx = realT > datetime('4/20/2020','InputFormat','MM/dd/yyyy') - days(24-recovDay) & ...
    realT < datetime('4/22/2020','InputFormat','MM/dd/yyyy') - days(24-recovDay);
MSEstudy2 = mean( (0.21 - mean(r(studyTindx))).^2 );


% objective function combines the two MSEs
% minthis = MSE/mean(thisCumDeath) + MSEstudy/0.15 + MSEstudy2/0.21;
% minthis = MSE/mean(thisCumDeath) + MSEstudy2/0.21;
minthis = MSE;
