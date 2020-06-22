clear 
close all

% define colors
basicColors = [0, 0.4470, 0.7410;...
    0.8500, 0.3250, 0.0980;...
    0.9290, 0.6940, 0.1250];
lightColors = [.16, .612, 1;...
    .969, .478, .271;...
    1, .792, .294];
darkColors = [0, .329, .545;...
.627, .22, .47;...
.698, .51, .059];

% generate legible y-axis
pop = 100000;
ypop = 0:pop/5:pop;
for k = 1:numel(ypop)
    yticklabel{k} = sprintf('%d',ypop(k));
end

% fig 1
i0 = 0.001;
ifr = 0;
transRate = 0.1;
recovDay = 1/0.05;
ndays = 365;
inter = 24;

[s,i,r,d,t] = calculate_SIRD(i0,ifr,transRate,recovDay,ndays,inter);

% figures
figure(1)
dim = [3,3,19,10];
set(1,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
plot(t,[s;i;r]'*pop,'linewidth',3);
legend('location','eastoutside',...
    {'Susceptible','Infected','Recovered'})
ylabel('Number of people')
xlabel('Days')
ax=gca;grid on;
set(ax,'box','off')
set(ax,'FontSize',12)
set(ax,'Xlim',[0,365])
set(ax,'ytick',ypop,'yticklabel',yticklabel)
saveas(1,fullfile(pwd,'teaching figs','Fig 1.png'))

% fig 2/3
i0 = 0.001;
ifr = 0;
transRate = 0.1;
recovDay = 1/0.05;
ndays = 365;
inter = 24;
pop = 100000;

[s1x,i1x,r1x,d,t] = calculate_SIRD(i0,ifr,transRate,recovDay,ndays,inter);

i0 = 0.001;
ifr = 0;
transRate = 0.1*2;
recovDay = 1/0.05/2;
ndays = 365;
inter = 24;
pop = 100000;

[s2x,i2x,r2x,d,t] = calculate_SIRD(i0,ifr,transRate,recovDay,ndays,inter);

i0 = 0.001;
ifr = 0;
transRate = 0.1/2;
recovDay = 1/0.05*2;
ndays = 365;
inter = 24;
pop = 100000;

[sHalfx,iHalfx,rHalfx,d,t] = calculate_SIRD(i0,ifr,transRate,recovDay,ndays,inter);
% figures
figure(1)
dim = [3,3,19,10];
set(1,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
plot(t,[s1x;i1x;r1x]'*pop,'linewidth',3);hold on;

plot(t,s2x'*pop,'linewidth',3,'color',lightColors(1,:));
plot(t,i2x'*pop,'linewidth',3,'color',lightColors(2,:));
plot(t,r2x'*pop,'linewidth',3,'color',lightColors(3,:));

% plot(t,sHalfx'*pop,'linewidth',3,'color',darkColors(1,:));
% plot(t,iHalfx'*pop,'linewidth',3,'color',darkColors(2,:));
% plot(t,rHalfx'*pop,'linewidth',3,'color',darkColors(3,:));

hold off;

legend('location','eastoutside',...
    {'Susceptible - Normal','Infected - Normal','Recovered - Normal',...
    'Susceptible - Fast','Infected - Fast','Recovered - Fast',})
ylabel('Number of people')
xlabel('Days')
ax=gca;grid on;
set(ax,'box','off')
set(ax,'FontSize',12)
set(ax,'Xlim',[0,365])
set(ax,'ytick',ypop,'yticklabel',yticklabel)



saveas(1,fullfile(pwd,'teaching figs','Fig 2.png'))


% fig 3
i0 = 0.001;
ifr = 0;
transRate = 0.1;
recovDay = 1/0.05;
ndays = 365;
inter = 24;
pop = 100000;

[s1x,i1x,r1x,d,t] = calculate_SIRD(i0,ifr,transRate,recovDay,ndays,inter);

i0 = 0.001;
ifr = 0;
transRate = 0.1*2;
recovDay = 1/0.05;
ndays = 365;
inter = 24;
pop = 100000;

[s2x,i2x,r2x,d,t] = calculate_SIRD(i0,ifr,transRate,recovDay,ndays,inter);

% figures
figure(1)
dim = [3,3,19,10];
set(1,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
plot(t,[s1x;i1x;r1x]'*pop,'linewidth',3);hold on;

plot(t,s2x'*pop,'linewidth',3,'color',lightColors(1,:));
plot(t,i2x'*pop,'linewidth',3,'color',lightColors(2,:));
plot(t,r2x'*pop,'linewidth',3,'color',lightColors(3,:));

hold off;

legend('location','eastoutside',...
    {'Susceptible - R_0 = 2','Infected - R_0 = 2','Recovered - R_0 = 2',...
    'Susceptible - R_0 = 4','Infected - R_0 = 4','Recovered - R_0 = 4',})
ylabel('Number of people')
xlabel('Days')
ax=gca;grid on;
set(ax,'box','off')
set(ax,'FontSize',12)
set(ax,'Xlim',[0,365])
set(ax,'ytick',ypop,'yticklabel',yticklabel)
saveas(1,fullfile(pwd,'teaching figs','Fig 3.png'))


% fig 4
i0 = 0.001;
ifr = 0;
transRate = 0.1;
recovDay = 1/0.05;
ndays = 365;
inter = 24;
pop = 100000;

[s,i,r,d,t] = calculate_SIRD(i0,ifr,transRate,recovDay,ndays,inter);
rt = s'*transRate*recovDay;
[~,peakIndx] = max(i);

% figures
close 1
figure(1)
dim = [3,3,19,13];
set(1,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
ax = axes;
plot(t,[s;i;r]'*pop,'linewidth',3);hold on;
plot([0,0],[0,0],'-k','linewidth',3);
plot([t(peakIndx),t(peakIndx)],[0,100000],'--k')
legend('location','eastoutside',...
    {'Susceptible','Infected','Recovered','R_t','Turning point'})
ylabel('Number of people')
xlabel('Days')
ax=gca;grid on;
set(ax,'box','off')
set(ax,'FontSize',12)
set(ax,'Xlim',[0,365])
set(ax,'ytick',ypop,'yticklabel',yticklabel)
set(ax,'Position',[0.15 0.55 0.6 0.4])

figure(1)
ax = axes;
plot(t,rt,'-k','linewidth',3);hold on;
plot([t(peakIndx),t(peakIndx)],[0,2],'--k'); hold off
ylabel('R_t')
xlabel('Days')
ax=gca;grid on;
set(ax,'box','off')
set(ax,'FontSize',12)
set(ax,'Xlim',[0,365])
set(ax,'Position',[0.15 0.15 0.6 0.2])

saveas(1,fullfile(pwd,'teaching figs','Fig 4.png'))

