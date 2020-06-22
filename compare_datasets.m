clear
close all

% jhu data
[jhu.datatable,jhu.date] = load_jhu;
nycindx = strcmp(jhu.datatable.Admin2,'New York') & ...
strcmp(jhu.datatable.Province_State,'New York');
jhu.thisCumDeath = jhu.datatable{nycindx,13:end};

% nytimes
[nyt.datatable] = load_nytimes;
nycindx = strcmp(nyt.datatable.county,'New York City');
nyt.thisCumDeath = nyt.datatable.deaths(nycindx);
nyt.date = nyt.datatable.date(nycindx);

% nyc health official stats
[nych.datatable] = load_nychealth_data;
nych.thisDailyDeath = nych.datatable.CONFIRMED_COUNT + ...
    nych.datatable.PROBABLE_COUNT;
nych.date = nych.datatable.date_of_death;
nych.thisCumDeath = cumsum(nych.thisDailyDeath);

% figures
lw = 2;
dim = [3,3,12,10];

% daily deaths
figure(1)
set(1,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
plot(jhu.date(2:end),diff(jhu.thisCumDeath),'-b','linewidth',lw); hold on;
plot(nyt.date(2:end),diff(nyt.thisCumDeath),'-r','linewidth',lw)
plot(nych.date,nych.thisDailyDeath,'-g','linewidth',lw)
hold off; grid on; box off;
set(gca,'XLim',[datetime('10-Mar-2020'),jhu.date(end)+days(2)])
set(gca,'FontSize',12)
legend({'JHU data','NYTimes data','NYC Dept. of Health data'},'location','northwest')
ylabel('Daily Deaths')
title('Comparing NYC deaths by dataset')

% cumulative deaths
figure(2)
set(2,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
plot(jhu.date,jhu.thisCumDeath,'-b','linewidth',lw); hold on;
plot(nyt.date,nyt.thisCumDeath,'-r','linewidth',lw)
plot(nych.date,nych.thisCumDeath,'-g','linewidth',lw)
hold off; grid on;box off;
set(gca,'XLim',[datetime('10-Mar-2020'),jhu.date(end)+days(2)])
set(gca,'FontSize',12)
legend({'JHU data','NYTimes data','NYC Dept. of Health data'},'location','northwest')
ylabel('Cumulative Deaths')
title('Comparing NYC deaths by dataset')

