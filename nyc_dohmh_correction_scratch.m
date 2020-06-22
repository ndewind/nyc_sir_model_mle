table0428 = readtable('C:\Users\Nick\Google Drive\Matlab\Personal\Corona\SIR model\nyc_dohmh_data\nyc_dohmh_data 2020_04_28.csv');
table0504 = readtable('C:\Users\Nick\Google Drive\Matlab\Personal\Corona\SIR model\nyc_dohmh_data\nyc_dohmh_data 2020_05_04.csv');



ndates = numel(table0428.PROBABLE_COUNT);
ndates2 = sum(table0504.date_of_death <= table0428.date_of_death(end));
assert(ndates==ndates2,'date mismatch')
indx = table0504.date_of_death <= table0428.date_of_death(end);
missingDeaths = (table0504.PROBABLE_COUNT(indx) + table0504.CONFIRMED_COUNT(indx)) - ...
    (table0428.PROBABLE_COUNT + table0428.CONFIRMED_COUNT);
correction = ...
    (missingDeaths + table0428.PROBABLE_COUNT + table0428.CONFIRMED_COUNT) ./...
    (table0428.PROBABLE_COUNT + table0428.CONFIRMED_COUNT);

table0428.PROBABLE_COUNT(isnan(table0428.PROBABLE_COUNT)) = 0;
plot(table0428.date_of_death,...
    table0428.PROBABLE_COUNT + table0428.CONFIRMED_COUNT)
hold on;
table0504.PROBABLE_COUNT(isnan(table0504.PROBABLE_COUNT)) = 0;
plot(table0504.date_of_death,...
    table0504.PROBABLE_COUNT + table0504.CONFIRMED_COUNT)

ndatediff = numel(table0504.date_of_death) - ndates;
plot(table0504.date_of_death(ndatediff+1:end),...
    (table0504.PROBABLE_COUNT(ndatediff+1:end) +...
    table0504.CONFIRMED_COUNT(ndatediff+1:end)) .* correction)