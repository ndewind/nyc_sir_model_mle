% load nyc doh data
[datatable] = load_nychealth_data;
datatable = datatable(1:end-7,:); % cut off the last week
firstDay = datatable.date_of_death(1);
daysFromJan2020 = round(days(firstDay - datetime('1-Jan-2020')));
for kday = 1:daysFromJan2020
    datatable = [{firstDay-days(kday),0,0};datatable];
end
save('dohdata','datatable')
allDate = datatable.date_of_death;

% extract NYC cummulative death data
thisCumDeath = cumsum(datatable.CONFIRMED_COUNT+datatable.PROBABLE_COUNT);
thisDailyDeath = (datatable.CONFIRMED_COUNT+datatable.PROBABLE_COUNT);
% firstDeathIndx = find(thisDailyDeath>0,1,'first');
allDate = datatable.date_of_death;

startindx = find(allDate == datetime('8-Apr-2020'));
testDD = thisDailyDeath(startindx:end);

x = [ones(numel(testDD),1),(1:numel(testDD))'];
[b,bint,r,rint,stats] = regress(log10(testDD),x);

figure(1)
plot(allDate(startindx:end),log10(testDD));
hold on;
plot(allDate(startindx:end),b'*x');

figure(2)
plot(allDate(startindx:end),(testDD));
hold on;
plot(allDate(startindx:end),10.^(b'*x'));

likMapRes = 100;
interceptsMinMax = [2.92,2.96];
intercepts = interceptsMinMax(1):range(interceptsMinMax)/likMapRes:interceptsMinMax(2);
slopesMinMax = [-0.026,-0.022];
slopes = slopesMinMax(1):range(slopesMinMax)/likMapRes:slopesMinMax(2);
[testB1,testB2] = meshgrid(intercepts,slopes);

nll = NaN(numel(testB1),1);
P = zeros(numel(testB1),numel(testDD));
for ktest = 1:numel(testB1)
    lambda = 10.^ ([testB1(ktest);testB2(ktest)]'*x');
    % lambda = 10.^(b'*x');
    for k = 1:numel(testDD)
        P(ktest,k) = pdf('Poisson',testDD(k),lambda(k));
    end
    nll(ktest) = -sum(log(P(ktest,:)));
end
[maxLL,maxLLindx] = min(nll);
[testB1(maxLLindx),testB2(maxLLindx);b']

figure(2)
plot(allDate(startindx:end),10.^([testB1(maxLLindx);testB2(maxLLindx)]'*x'));
hold off

figure(3)
logLikMap = reshape(sum(log(P),2),size(testB1));
% logLikMap(logLikMap < max(sum(log(P),2)) - 2) = NaN;
likMap = reshape(prod((P),2),size(testB1));
% surf(intercepts,slopes,likMap)
surf(intercepts,slopes,logLikMap)
[sub1,sub2] = ind2sub(size(testB1),maxLLindx);
hold on;
plot3(testB1(maxLLindx),testB2(maxLLindx),logLikMap(sub1,sub2),'*r');
hold off;

% https://web.stanford.edu/class/archive/stats/stats200/stats200.1172/Lecture22.pdf
logL = logLikMap - logLikMap(sub1,sub2);
imagesc(intercepts,slopes,-2*logL)
df = 2;
alpha = 0.025;
plausibleParms = pdf('chi2',-2*logL,df) > alpha; % 95% parameter area
imagesc(intercepts,slopes,plausibleParms)
ci = [min(testB1(plausibleParms)),max(testB1(plausibleParms));...
    min(testB2(plausibleParms)),max(testB2(plausibleParms))]
bint
