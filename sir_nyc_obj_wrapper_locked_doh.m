function [minthis] = sir_nyc_obj_wrapper_locked_doh(x)
% this version only has 3 free paramters. i0, early trans, and late trans

% values for debugging
% x = [0.0007, 0.36, 0.48]

% free parameters
i0 = x(1);
transRate = x(2)^2;
newTransRate = x(3)^2;
ifr = x(4);

% static parameters (globals)
global recovDay
global lingerDays
% global ifr
% recovDay = 14;
% lingerDays = 13;
recovDay = 21;
lingerDays = 13-7;
% ifr = 0.01;

% fixed parameters
ndays = 90;
inter = 24;
nycpop = 8398748;

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
realLockDownDay = datetime('3/22/2020','InputFormat','MM/dd/yyyy');
lockdownDay = find(allDate == realLockDownDay)-1;

% calculate parameter predictions
[s,i,r,d,t] = calculate_fancy_SIRD(...
    i0,ifr,transRate,recovDay,ndays,inter,lockdownDay,newTransRate);

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

% objective function combines the two MSEs
minthis = MSE/mean(thisCumDeath) + MSEstudy/0.15;
% minthis = MSE;

% figures
% figure(1)
% plot(realT,[s;i;r;d]','linewidth',2);
% hold on;
% plot(realT(studyTindx),repmat(0.15,1,sum(studyTindx)),'-g','linewidth',2)
% plot([realLockDownDay,realLockDownDay],[0,1],...
%     '--k','linewidth',1.5)
% hold off;
% legend('location','southoutside',...
%     {'Susceptible','Infected','Recovered','Dead','Est. Infect.','Lockdown'})
% ylabel('Proportion of population')
% xlabel('Days')
% set(gca,'XLim',[realT(1),realT(end)])
% set(gca,'YLim',[0,1])
% 
% 
% figure(2)
% plot(realT,[s;i;r;d]','linewidth',2);
% hold on;
% plot(allDate,thisCumDeath,'linewidth',2);
% plot([realLockDownDay,realLockDownDay],[0,1],...
%     '--k','linewidth',1.5)
% hold off;
% legend('location','southoutside',...
%     {'Susceptible','Infected','Recovered','Dead','NYC real deaths','Lockdown'})
% ylabel('Proportion of population')
% set(gca,'XLim',[realT(1),allDate(end)+range(allDate)/10])
% set(gca,'YLim',[0,max(thisCumDeath)+max(thisCumDeath)/10])
