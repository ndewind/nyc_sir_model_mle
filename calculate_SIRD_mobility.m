function [s,i,r,d,t] = calculate_SIRD_mobility(i0,ifr,transRate,recovDay,ndays,inter)
% i0 - portion of population infected at t0
% ifr - infection fatality ratio
% transRate - transmision rate. Number of contacts each person has per day
%         times the probability that a contact between susceptible and
%         infected results in transmission
% recovDay - number of days for an infected person to die or recover
% ndays - number of days to run simulation
% inter - number of intervals per day (24 to simulate with hour level
%         granularity

t = 0; % time
i = i0; % infected
s = 1-i0; % suseptible
r = 0; % recovered + dead
trans = transRate./inter;
recov(1) = 1/recovDay/inter; % recovery + death rate. daily rate of moving from infected to removed
iters = ndays*inter; % number of iterations

for kt = 1:iters
    
    Sp = -trans(kt)*s(kt)*i(kt);
    Ip = trans(kt)*s(kt)*i(kt) - recov*i(kt);
    Rp = recov*i(kt);
    
    s(kt+1) = s(kt)+Sp;
    i(kt+1) = i(kt)+Ip;
    r(kt+1) = r(kt)+Rp;
    
    t(kt+1) = t(kt)+1/inter;
    
end

d = r*ifr;
r = r-d;