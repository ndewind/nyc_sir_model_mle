function [s,i,r,d,t] = calculate_fancy_reopen_SIRD(i0,ifr,transRate,recovDay,ndays,inter,lockdownDay,newTransRate,reopenDay,reOpTransRate)
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
trans(1) = transRate/inter;
recov(1) = 1/recovDay/inter; % recovery + death rate. daily rate of moving from infected to removed
newTrans = newTransRate/inter;
iters = ndays*inter; % number of iterations

for kt = 1:iters
    
    if t(kt) < lockdownDay
        Sp = -trans*s(kt)*i(kt);
        Ip = trans*s(kt)*i(kt) - recov*i(kt);
        Rp = recov*i(kt);
    elseif t(kt) >= lockdownDay & t(kt) < reopenDay
        Sp = -newTrans*s(kt)*i(kt);
        Ip = newTrans*s(kt)*i(kt) - recov*i(kt);
        Rp = recov*i(kt);
    else
        Sp = -reOpTrans*s(kt)*i(kt);
        Ip = reOpTrans*s(kt)*i(kt) - recov*i(kt);
        Rp = recov*i(kt);
    end
    
    s(kt+1) = s(kt)+Sp;
    i(kt+1) = i(kt)+Ip;
    r(kt+1) = r(kt)+Rp;
    
    t(kt+1) = t(kt)+1/inter;
    
end

d = r*ifr;
r = r-d;


% mdlPred = [];mdlT=[];
% for kt = 1:numel(y)
%     [~,tindx] = min( abs(t - (kt-1)) );
%     mdlT(kt,1) = t(tindx);
%     mdlPred(kt,1) = r(tindx)*ifr;
% end

%     plot(mdlT,mdlPred)
%     hold off;

% mdls.mse(kmdl,1) = mean( (y-mdlPred).^2);