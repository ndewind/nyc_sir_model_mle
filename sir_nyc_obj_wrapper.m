function [minthis] = sir_nyc_obj_wrapper(x)

% values for debugging
x = [0.008, 0.0075, 0.2, 15, 0.15]

% free parameters
i0 = x(1);
ifr = x(2);
transRate = x(3);
recovDay = x(4);
newTransRate = x(5);

% r0 and lockdown r0
[transRate*recovDay,newTransRate*recovDay]

% fixed parameters
ndays = 90;
inter = 24;
% lockdownDay = 25;
nycpop = 8398748;

% load jhu data
[datatable,allDate] = load_jhu;

% extract NYC cummulative death data
nycindx = strcmp(datatable.Admin2,'New York') & ...
strcmp(datatable.Province_State,'New York');
thisCumDeath = datatable{nycindx,13:end} / nycpop;
firstDeathIndx = find(thisCumDeath>0,1,'first');
thisCumDeath = thisCumDeath(firstDeathIndx:end);
allDate = allDate(firstDeathIndx:end);

% lockdown date for NYC
realLockDownDay = datetime('3/22/2020','InputFormat','MM/dd/yyyy');
lockdownDay = find(allDate == realLockDownDay)-1;

% calculate parameter predictions
[s,i,r,d,t] = calculate_fancy_SIRD(...
    i0,ifr,transRate,recovDay,ndays,inter,lockdownDay,newTransRate);

% create hourly time axis with real date
realT = allDate(1) + t;

% compare model to NYC data
yhat = d(1:inter:numel(thisCumDeath)*inter);
MSE = mean( (yhat-thisCumDeath).^2 );

% constrain with pregnancy study
studyTindx = realT > datetime('3/22/2020','InputFormat','MM/dd/yyyy') & ...
    realT < datetime('4/4/2020','InputFormat','MM/dd/yyyy');
MSEstudy = mean( (0.15 - i(studyTindx)).^2 );

% objective function combines the two MSEs
minthis = MSE + MSEstudy;

% figures
figure(1)
plot(realT,[s;i;r;d]','linewidth',2);
hold on;
plot(realT(studyTindx),repmat(0.15,1,sum(studyTindx)),'-g','linewidth',2)
plot([realLockDownDay,realLockDownDay],[0,1],...
    '--k','linewidth',1.5)
hold off;
legend('location','southoutside',...
    {'Susceptible','Infected','Recovered','Dead','Est. Infect.','Lockdown'})
ylabel('Proportion of population')
xlabel('Days')
set(gca,'XLim',[realT(1),realT(end)])
set(gca,'YLim',[0,1])


figure(2)
plot(realT,[s;i;r;d]','linewidth',2);
hold on;
plot(allDate,thisCumDeath,'linewidth',2);
plot([realLockDownDay,realLockDownDay],[0,1],...
    '--k','linewidth',1.5)
hold off;
legend('location','southoutside',...
    {'Susceptible','Infected','Recovered','Dead','NYC real deaths','Lockdown'})
ylabel('Proportion of population')
set(gca,'XLim',[realT(1),allDate(end)+range(allDate)/10])
set(gca,'YLim',[0,max(thisCumDeath)+max(thisCumDeath)/10])
