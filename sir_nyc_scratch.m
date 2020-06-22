% between march 22 and april 4 the number of infected was about 15%
% the ifr is 0.75
% after the lockdown day transmission rate changed to a new value (also fit
% to data). 

% recovery days = 15 (https://www.nature.com/articles/s41591-020-0869-5)


[datatable,allDate] = load_jhu;
save('jhudata','datatable','allDate')

% fit model
options = optimset('Display','iter');
% x0 = [0.0008, 0.0075, 0.25, 15, 0.25];
% [x,fval,exitflag,output] = fminsearch(@sir_nyc_obj_wrapper,x0,options)
x0 = [0.00007, 0.36, 0.048];
[x,fval,exitflag,output] = ...
    fminsearch(@sir_nyc_obj_wrapper_locked,x0,options)

% extract model parameters
i0 = x(1);
ifr = 0.008;
% ifr = x(6);
transRate = x(2);
newTransRate = x(3);
recovDay = 14;
lingerDays = 14;

% r0 and lockdown r0
[transRate*recovDay,newTransRate*recovDay]

% fixed parameters
ndays = 180;
inter = 24;
% lockdownDay = 25;
nycpop = 8398748;

% load jhu data
% load('jhudata 04_16','datatable','allDate')
load('jhudata','datatable','allDate')

% extract NYC cummulative death data
nycindx = strcmp(datatable.Admin2,'New York') & ...
strcmp(datatable.Province_State,'New York');
thisCumDeath = datatable{nycindx,13:end} / nycpop;
firstDeathIndx = find(thisCumDeath>0,1,'first');
thisCumDeath = thisCumDeath(firstDeathIndx-21:end-1)*1.3;
allDate = allDate(firstDeathIndx-21:end-1);

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

% pregnancy study time index
studyTindx = realT > datetime('3/22/2020','InputFormat','MM/dd/yyyy') & ...
    realT < datetime('4/4/2020','InputFormat','MM/dd/yyyy');

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
ax=gca;grid on;
set(ax,'box','off')
set(ax,'XLim',[realT(1),realT(end)])
set(ax,'YLim',[0,1])


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
ax = gca;grid on;
set(ax,'box','off')
set(ax,'XLim',[realT(1),allDate(end)+range(allDate)/10])
set(ax,'YLim',[0,max(thisCumDeath)+max(thisCumDeath)/10])

figure(3)
plot(realT,[s;i;r;d]','linewidth',2);
hold on;
plot(allDate,thisCumDeath,'linewidth',2);
plot([realLockDownDay,realLockDownDay],[0,1],...
    '--k','linewidth',1.5)
hold off;
legend('location','southoutside',...
    {'Susceptible','Infected','Recovered','Dead','NYC real deaths','Lockdown'})
ylabel('Proportion of population')
ax = gca;grid on;
set(ax,'box','off')
set(ax,'XLim',[realT(1),realT(end)])
set(ax,'YLim',[0,max(d)+max(d)/10])

figure(4)
% build log y-axis with interpretable intervals and labels
yticks = [1,2,5];
for kom = 1:9
    yticks = [yticks,[1,2,5]*10^kom];
end
clear yticklabelarray
for ky = 1:numel(yticks)
    yticklabelarray{ky} = sprintf('%d',yticks(ky));
end
predDD = diff(d(1:inter:end))*nycpop;
dd = diff(thisCumDeath)*nycpop;
plot(allDate(2:end),log10(dd),'linewidth',2); hold on;
plot(log10(predDD),'linewidth',2); hold off;
set(gca,'ytick',log10(yticks),'yticklabel',yticklabelarray)
legend('location','southoutside',...
    {'NYC deaths(adjusted for home deaths)','Model predicted deaths'})
ylabel('Deaths per day')
ax = gca;grid on;
set(ax,'box','off')
set(ax,'XLim',[realT(1),realT(end)])
set(ax,'YLim',[0,max(log10(dd))+max(log10(dd))/10])
