% sir model
clear;

% things to fit i,cfr,trans
i0s = 10.^(-4:.1:-1);
cfrs = 10.^(-4:.1:-2);
transs = 10.^(-1.5:.1:0.5);
recovDays = 10.^(0:.05:1.8);
[x,y,z,a] = ndgrid(i0s,cfrs,transs,recovDays);
mdls.params = [x(:),y(:),z(:),a(:)];
[x,y,z,a] = ndgrid(1:numel(i0s),1:numel(cfrs),1:numel(transs),1:numel(recovDays));
mdls.paramIndices = [x(:),y(:),z(:),a(:)];

% data to fit
load('italy data')
pop = 10.04e6; % lombardy
y = region.cumdeaths{strcmp(region.name,'Lombardia')}./pop;

for kmdl = 1:size(mdls.params,1)
    
    fprintf('Model %d / %d\n',kmdl,size(mdls.params,1))
    
    t = 0; % time
    i = mdls.params(kmdl,1); % infected
    s = 1; % suseptible
    r = 0; % recovered + dead
    
    inter = 24; % interval per day
    
    % cfr = 0.01
    cfr = mdls.params(kmdl,2);
    
    % transmision rate. Number of contacts each person per time increment times
    % the probability that a contact results in transmision.
    % trans(1) = .12/inter;
    trans(1) = mdls.params(kmdl,3)/inter;
    % recovery rate. contacts minus
    recov(1) = (1/mdls.params(kmdl,4))/inter; % recovery + death rate. daily rate of moving from infected to removed
    %     r0 = trans/recov;
    
    iters = 90*inter; % iterations
    
    for kt = 1:iters
        
        Sp = -trans*s(kt)*i(kt);
        Ip = trans*s(kt)*i(kt) - recov*i(kt);
        Rp = recov*i(kt);
        
        s(kt+1) = s(kt)+Sp;
        i(kt+1) = i(kt)+Ip;
        r(kt+1) = r(kt)+Rp;
        
        t(kt+1) = t(kt)+1/inter;
        
    end
    
    %     figure(1)
    %     indx = 1:numel(t);
    %     plot(t(indx),[s(indx);i(indx);r(indx)*cfr;r(indx)-(r(indx)*cfr)]')
    %     % plot(t(indx),[r(indx)*cfr]')
    %     legend('location','eastoutside',...
    %         {'Susceptible','Infectious','Dead','Recovered'});
    %     xlabel('Day');
    %     ylabel('Proportion total pop.')
    %     title(sprintf('Basic SIR model\nTransmission rate: %0.2f/day Recovery rate: %0.2f/day',trans*inter,recov*inter))
    
    %     figure(2)
    %     indx = 1:numel(t);
    %     plot(t(indx),[r(indx)*cfr]')
    %     xlabel('Day');
    %     ylabel('Proportion total pop.')
    %     title(sprintf('Basic SIR model\nTransmission rate: %0.2f/day Recovery rate: %0.2f/day',trans*inter,recov*inter))
    %     hold on;
    %     plot([1:numel(region.cumdeaths{strcmp(region.name,'Lombardia')})],...
    %         region.cumdeaths{strcmp(region.name,'Lombardia')}./10^7,'r')
    %     %     hold off;
    %     legend('location','eastoutside',...
    %         {'Model Dead','Lombardia Dead'});
    %     axis([0,50,0,1.6e-3])
    
    mdlPred = [];mdlT=[];
    for kt = 1:numel(y)
        [~,tindx] = min( abs(t - (kt-1)) );
        mdlT(kt,1) = t(tindx);
        mdlPred(kt,1) = r(tindx)*cfr;
    end
    
    %     plot(mdlT,mdlPred)
    %     hold off;
    
    mdls.mse(kmdl,1) = mean( (y-mdlPred).^2);
    
end

scaleFactor=1.5;
set(0,'DefaultAxesFontSize',7*scaleFactor);
set(0,'defaulttextfontsize',7*scaleFactor);
set(0,'defaultAxesFontName','Helvetica');
set(0,'defaultTextFontName','Helvetica');
set(0,'defaultLineLineWidth',0.5*scaleFactor);
set(0,'defaultBarLineWidth',0.5*scaleFactor);
set(0,'defaultErrorBarLineWidth',0.5*scaleFactor);
set(0,'defaultAxesLineWidth',0.5*scaleFactor);

% figure(3)
% plot(mdls.mse)

mseMatrix = reshape(mdls.mse,...
    [numel(i0s),numel(cfrs),numel(transs),numel(recovDays)]);
[~,sortedMSEindx] = sort(mdls.mse);
bestIndx = sortedMSEindx(1)

% plot best model
kmdl = bestIndx;

fprintf('Model %d / %d\n',kmdl,size(mdls.params,1))
[mdls.params(kmdl,:);...
    mdls.paramIndices(kmdl,:);...
    numel(i0s),numel(cfrs),numel(transs ),numel(recovDays )]

t = 0; % time
i = mdls.params(kmdl,1); % infected
s = 1; % suseptible
r = 0; % recovered + dead

inter = 24; % interval per day

% cfr = 0.01
cfr = mdls.params(kmdl,2);



% transmision rate. Number of contacts each person per time increment times
% the probability that a contact results in transmision.
% trans(1) = .12/inter;
trans(1) = mdls.params(kmdl,3)/inter;
% recovery rate. contacts minus
recov(1) = (1/mdls.params(kmdl,4))/inter; % recovery + death rate. daily rate of moving from infected to removed
r0 = trans/recov;

iters = 365*inter; % iterations

for kt = 1:iters
    
    Sp = -trans*s(kt)*i(kt);
    Ip = trans*s(kt)*i(kt) - recov*i(kt);
    Rp = recov*i(kt);
    
    s(kt+1) = s(kt)+Sp;
    i(kt+1) = i(kt)+Ip;
    r(kt+1) = r(kt)+Rp;
    
    t(kt+1) = t(kt)+1/inter;
    
end

figure(1)
dim = [5,5,19,10];
set(1,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
indx = 1:numel(t);
plot(t(indx),[s(indx);i(indx);r(indx)*cfr;r(indx)-(r(indx)*cfr)]');hold on;
plot([numel(y),numel(y)]-1,[0,1],'--k'); hold off;
% plot(t(indx),[r(indx)*cfr]')
legend('location','eastoutside',...
    {'Susceptible','Infectious','Dead','Recovered','Today'});
xlabel('Day');
ylabel('Proportion total pop.')
title(sprintf('Basic SIR model fit to Lombardy Data (pop: 10.04M)\nTransmission rate: %0.2f/day Days to recovery: %0.2f\n Infection Rate on Day 0: %0.2g%%\nInfection Rate Today: %0.2f%% Dead at 1 year: %d\nInfection Fatality Rate (IFR): %0.2f%%',...
    trans*inter,(1/recov)/inter,i(1)*100,i(numel(y)*inter)*100,round(r(end)*cfr*pop),cfr*100))
axis([0,365,0,1])
grid on;box off;

figure(2)
dim = [5,5,19,10];
set(2,'units','centimeter','position',dim,'paperunits','centimeter','paperposition',dim)
indx = 1:numel(t);
plot(t(indx),[r(indx)*cfr*pop]')
xlabel('Day');
ylabel('Cumulative deaths')
title(sprintf('Basic SIR model fit to Lombardy Data (pop: 10.04M)\nTransmission rate: %0.2f/day Days to recovery: %0.2f\n Infection Rate on Day 0: %0.2g%%\nInfection Rate Today: %0.2f%% Dead at 1 year: %d\nInfection Fatality Rate (IFR): %0.2f%%',...
    trans*inter,(1/recov)/inter,i(1)*100,i(numel(y)*inter)*100,round(r(end)*cfr*pop),cfr*100))
hold on;
plot([1:numel(region.cumdeaths{strcmp(region.name,'Lombardia')})]-1,y*pop,'r')
plot([numel(y),numel(y)]-1,[0,max(y*pop)+max(y*pop)*.1],'--k')
%     hold off;
legend('location','eastoutside',...
    {'Model Dead','Lombardia Dead','Today'});
axis([0,43,0,max(y*pop)+max(y*pop)*.1])
grid on;box off;
mdlPred = [];mdlT=[];
for kt = 1:numel(y)
    [~,tindx] = min( abs(t - (kt-1)) );
    mdlT(kt,1) = t(tindx);
    mdlPred(kt,1) = r(tindx)*cfr;
end

% plot(mdlT,mdlPred)
hold off;


% 
% figure(4)
% [mdls.params(kmdl,:);...
%     mdls.paramIndices(kmdl,:);...
%     numel(i0s),numel(cfrs),numel(transs ),numel(recovDays )]
% imagesc(...
%     log10(squeeze(mseMatrix(...
%     :,:,mdls.paramIndices(kmdl,3),mdls.paramIndices(kmdl,4)))),...
%     log10([min(mdls.mse(:)),max(mdls.mse(:))]))
% title('cfrs x i0s')
% 
% imagesc(...
%     log10(squeeze(mseMatrix(...
%     mdls.paramIndices(kmdl,1),mdls.paramIndices(kmdl,2),:,:))),...
%     log10([min(mdls.mse(:)),max(mdls.mse(:))]))
% title('recov x trans')
% 
% imagesc(...
%     log10(squeeze(mseMatrix(...
%     mdls.paramIndices(kmdl,1),:,mdls.paramIndices(kmdl,3),:))),...
%     log10([min(mdls.mse(:)),max(mdls.mse(:))]))
% title('recov x cfr')
% 
% imagesc(...
%     log10(squeeze(mseMatrix(...
%     :,mdls.paramIndices(kmdl,2),mdls.paramIndices(kmdl,3),:))),...
%     log10([min(mdls.mse(:)),max(mdls.mse(:))]))
% title('recov x i0s')
% 
% imagesc(...
%     log10(squeeze(mseMatrix(...
%     :,mdls.paramIndices(kmdl,2),:,mdls.paramIndices(kmdl,4)))),...
%     log10([min(mdls.mse(:)),max(mdls.mse(:))]))
% title('trans x i0s')
% 
% for k = 1:10
% % [~,indx] = min(mdls.mse(mdls.paramIndices(:,4) == k));
% plot3(mdls.paramIndices(sortedMSEindx(k),1),...
%     mdls.paramIndices(sortedMSEindx(k),3),...
%     mdls.paramIndices(sortedMSEindx(k),4),'*')
% hold on;
% grid on
% end
% hold off;

% logistic modeling
% [b,dev,states] = glmfit(t',r','binomial','link','logit')

% pred = glmval(b,t','logit')
% pred = 1./(1+exp(-(x-u)./s));

% x = t';
% y = r'*0.01;
% mdl = fit(x,y,'b3./(1+exp(b1+b2*x))','start',[ -1 1 1]);
% pred = mdl.b3./(1+exp(mdl.b1+mdl.b2*x));


