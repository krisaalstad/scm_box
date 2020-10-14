%%  Del 2. Historisk respons, Oblig 1 GEF1100
% Kjør modellen. 
% NB! Du behøver bare å kjøre den 1 gang, 
% bruk 'run section' i editor-menyen over for å kjøre
% de individuelle seksjonene hver for seg.

if exist('result.mat', 'file')==0  
  cd ../src;
  run_scm;
end

load('result.mat'); % Last opp strukturen med resultater.



%% [NY SEKSJON]: 2. a) Pådriv.

% Tidsvektor (i årstall).
t=result.historical.erf.t;              

% Historisk pådriv (Wm^{-2}).
dQ=result.historical.erf.dQ;            

% Navn til legenden: 
active=result.historical.erf.active(:,2:end);
active=active(~cellfun(@isempty, active));
names=['Total'; active];
clear active;

%--------------------------------------------------------------%
% Lag Figuren:

% Figur navn:
fh=figure('Name','2 a)','NumberTitle','off');

% Farger: 
c=0.85.*colormap(hsv(5));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');

% Grenser:
xl=[min(t) max(t)];
yl=[1.15*min(min(dQ)) 1.15*max(max(dQ))];

% Plott:
plot(t,dQ,'LineWidth',2) % Linje plott. 
grid minor; box on; axis('square'); set(gca,'TickDir','out'); % Kosmetikk.
xlim(xl);
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Radiative Forcing, $\Delta Q$ [Wm$^{-2}$]',...
    'FontSize',14,'Interpreter','Latex');
legend(names,'Location','SouthEast','FontSize',12,...
    'Interpreter','Latex');
titleis=sprintf('Historical Forcing %d-%d',min(t),max(t));
title(titleis,'FontSize',14,'Interpreter','Latex');
print(fh,'-dpdf','2a','-opengl','-r300'); 

%---------------------------------------------------------------%


%% [NY SEKSJON]: 2. b) Temperatur respons.

% Modellert temperaturanomali i blandingslaget for ulike pådriv.
dT1=result.historical.erf.dT1;   

%--------------------------------------------------------------%
% Lag Figuren:

% Figur navn:
fh=figure('Name','2 b)','NumberTitle','off');

% Farger: 
c=0.85.*colormap(hsv(5));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');

% Grenser:
xl=[min(t) max(t)];
yl=[1.15*min(min(dT1)) 1.15*max(max(dT1))];

% Plott:
plot(t,dT1,'LineWidth',2)    % Linje plott. 
grid minor; box on; axis('square'); set(gca,'TickDir','out'); % Kosmetikk.
xlim(xl);
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Temperature anomaly, $\Delta T_1$ [$^\circ$C]',...
    'FontSize',14,'Interpreter','Latex');
legend(names,'Location','SouthEast','FontSize',12,...
    'Interpreter','Latex');
titleis=sprintf('Response to Historical Forcing %d-%d',min(t),max(t));
title(titleis,'FontSize',14,'Interpreter','Latex');
print(fh,'-dpdf','2b','-opengl','-r300'); 

%---------------------------------------------------------------%

%% [NY SEKSJON]: 2. c) Sammenlinging med observasjoner.

% Modellert temperaturanomali i blandingslaget for total pådriv.
dTm=dT1(:,1);                   

% Observert (GISS) temperaturanomali definert i forhold til midlet
% over normalperioden 1950-1980:                              
dTo=result.historical.gistemp.dT;

% Tidsvektor for den observerte temperatur anomalien.
to=result.historical.gistemp.t;

% Snykroniserer den modellerte temperaturanomalien med den observerte:
dTm=dTm(t>=min(to)&t<=max(to));

% Redefiner den modellerte anomalien i forhold til midlet over
% normalperioden 1951-1980:
dTm=dTm-mean(dTm(to>=1951&to<=1980));

% Regn ut den lineære korrelasjonen mellom tidsseriene:
R=corr(dTm,dTo);


%--------------------------------------------------------------%
% Lag Figuren:

% Figur navn:
fh=figure('Name','2 c)','NumberTitle','off');

% Grenser:
xl=[min(to) max(to)];
yl=[1.15*min(min([dTo dTm])) 1.15*max(max([dTo dTm]))];

subplot(1,2,1);
% Farger: 
c=0.65.*[0 0 1; 0 1 0]; 
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');


% Plott:
plot(to,[dTm dTo],'LineWidth',2)    % Linje plott. 
grid minor; box on; axis('square'); set(gca,'TickDir','out'); % Kosmetikk.
xlim(xl);   
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Temperature anomaly [$^\circ$C]',...
    'FontSize',14,'Interpreter','Latex');
legend({'Modeled' 'Observed'},'Location','SouthEast','FontSize',14,...
    'Interpreter','Latex');
titleis=sprintf('Modeled vs. Observed %d-%d',...
    min(to),max(to));
title(titleis,'FontSize',14,'Interpreter','Latex');

sps=subplot(1,2,2);
plot([0 0],yl,'k','LineWidth',0.5); 
hold on;
plot(yl,[0 0],'k','LineWidth',0.5);
scatter(dTo,dTm,100,'.','MarkerEdgeColor',[0.6 0.6 0.6]);
l1=plot(yl,yl,'--k','LineWidth',2);
reg=polyfit(dTo,dTm,1); 
l2=plot(yl,polyval(reg,yl),'Color',[0.65 0 0],'LineWidth',2);
grid minor; box on; axis('square'); set(gca,'TickDir','out'); % Kosmetikk.
ylim(yl); xlim(yl);
xlabel('Observered anomaly [$^\circ$C]',...
    'FontSize',14,'Interpreter','Latex');
ylabel('Modeled anomaly [$^\circ$C]',...
    'FontSize',14,'Interpreter','Latex');
leg=legend([l1;l2],{'1:1' 'Linear Fit'},'Location','SouthEast',...
    'FontSize',14,'Interpreter','Latex');
titleis=sprintf('y=%4.2fx%4.2f , R=%4.2f',reg,R);
title(titleis,'FontSize',14,'Interpreter','Latex');
print(fh,'-dpdf','2c','-opengl','-r300'); 

%---------------------------------------------------------------%


