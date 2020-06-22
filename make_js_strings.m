clear

[datatable] = load_nychealth_data;

allSum = datatable.CONFIRMED_COUNT + datatable.PROBABLE_COUNT;
allcumsum = cumsum(allSum);

xstr = '';
ystrDaily = '';
ystrCum = '';
for k = 1:numel(datatable.date_of_death)
    thisDate = datestr(datatable.DATE_OF_DEATH(k),'yyyy-mm-dd');
    xstr = [xstr, sprintf('''%s'', ',thisDate)];
    thisSum = allSum(k);
    ystrDaily = [ystrDaily, sprintf('%d, ',thisSum)];
    ystrCum = [ystrCum, sprintf('%d, ',allcumsum(k))];
end