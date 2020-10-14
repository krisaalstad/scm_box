%%  Del 3. Fremtidig respons, Oblig 1 GEF1100
% Kjør modellen (run_scm). 
% NB! Du behøver bare å kjøre den 1 gang, 
% bruk 'run section' i editor-menyen over for å kjøre
% de individuelle seksjonene hver for seg.

if exist('result.mat', 'file')
  % Do nothing.
else
  run_scm
end

load('result.mat'); % Last opp strukturen med resultater.


%% [NY SEKSJON]: 3. a) RCP utvikling.

% Tidsvektor.
t=result.future.rcp.t;
tstop=2200;

% Navn på de ulike RCP scenariene.
name=result.future.rcp.name; name=[name 'Historical'];

% Pådriv i de ulike RCP scenariene.
dQ=result.future.rcp.dQ;    

% Temperaturanomali i de ulike RCP scenariene.
dT1=result.future.rcp.dT1;  

%--------------------------------------------------------------%
% Lag Figuren:

% Figur navn:
fh=figure('Name','3 a)','NumberTitle','off');

% Grenser:
xl=[min(t) max(t)];
yl=[1.15*min(min(dQ)) 1.15*max(max(dQ))];

subplot(1,2,1);
% Farger: 
c=flipud(0.85.*colormap(hsv(4)));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');


% Plott:
l1=plot(t,dQ,'LineWidth',2);    % Linje plott. 
hold on;
l2=plot(result.historical.erf.t(result.historical.erf.t<2004),...
    result.historical.erf.dQ(result.historical.erf.t<2004,1),...
    'k','LineWidth',2);
grid minor; box on; set(gca,'TickDir','out'); axis('square'); % Kosmetikk.
xlim(xl);   
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Radiative Forcing, $\Delta Q$ [Wm$^{-2}$]',...
    'FontSize',14,'Interpreter','Latex');
legend([l1;l2],name,'Location','SouthEast','FontSize',12,...
    'Interpreter','Latex');
title('RCP Scenarios','FontSize',14,'Interpreter','Latex');

subplot(1,2,2);
c=flipud(0.85.*colormap(hsv(4)));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');

% Plott:
plot(t,dT1,'LineWidth',2)    % Linje plott. 
hold on;
plot(result.historical.erf.t(result.historical.erf.t<2004),...
    result.historical.erf.dT1(result.historical.erf.t<2004,1),...
    'k','LineWidth',2);
grid minor; box on; set(gca,'TickDir','out'); axis('square'); % Kosmetikk.
xlim(xl);  
yl=[1.15*min(min(dT1)) 1.15*max(max(dT1))];
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Temperature anomaly, $\Delta T_1$ [$^\circ$C]',...
    'FontSize',14,'Interpreter','Latex');
title('Response','FontSize',14,'Interpreter','Latex');

print(fh,'-dpdf','3a','-opengl','-r300'); 

%% [NY SEKSJON]: 3. b) CO_2 utslipp og konsentrasjon.

% Tidsvektor.
t=result.future.emissions.t;
tstart=1750;
tstop=2500;
%tstop=2100;


% Utslipp [GtCO_2 per år].
E=result.future.emissions.E; 
Ec=cumsum(E);

E=E(t>=tstart&t<=tstop,:);
Ec=Ec(t>=tstart&t<=tstop,:);


% Konsentrasjon [ppm].
C=result.future.emissions.C;
C=C(t>=tstart&t<=tstop,:);

% Oppdater tidsvektoren.
t=t(t>=tstart&t<=tstop);

% Gi CO_2 utslippsscenariene navn:
name={'S1' 'S2' 'S3'};

%--------------------------------------------------------------%
% Lag Figuren:

% Figur navn:
fh=figure('Name','3 b)','NumberTitle','off');

% Grenser:
xl=[min(t) max(t)];
yl=[0.85*min(min(Ec)) 1.2*max(max(Ec))];

subplot(1,2,1);
% Farger: 
c=flipud(0.85.*colormap(hsv(3)));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');

% Plott:
l1=plot(t,Ec,'LineWidth',2);    % Linje plott. 
hold on;
l2=plot(t(t<=2010),Ec(t<=2010,1),...
    'k','LineWidth',2);
grid minor; box on; set(gca,'TickDir','out'); axis('square'); % Kosmetikk.
xlim(xl);   
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Cumulative CO$_2$ Emissions since 1750  [GtCO$_2$]',...
    'FontSize',8,'Interpreter','Latex');
name=[name 'Historical'];
legend([l1;l2],name,'Location','NorthWest','FontSize',8,...
    'Interpreter','Latex');
title('CO$_2$ Emission Scenarios','FontSize',12,'Interpreter','Latex');

subplot(1,2,2);
c=flipud(0.85.*colormap(hsv(3)));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');

% Plott:
l1=plot(t,C,'LineWidth',2);    % Linje plott. 
hold on;
l2=plot(t(t<=2010),C(t<=2010,1),'k','LineWidth',2);
grid minor; box on; set(gca,'TickDir','out'); axis('square'); % Kosmetikk.
xlim(xl); 
yl=[0.85*min(min(C)) 1.2*max(max(C))];
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Atmospheric CO$_2$ Concentration  [ppm]',...
    'FontSize',10,'Interpreter','Latex');
title('Resulting CO$_2$ Concentration','FontSize',14,'Interpreter','Latex');


print(fh,'-dpdf','3b','-opengl','-r300'); 


%% [NY SEKSJON]: 3. c) CO_2 pådriv og respons

% Tidsvektor.
t=result.future.emissions.t;
tstart=1750;
tstop=2500;
%tstop=2100;


% Pådriv [Wm^{-2}].
dQ=result.future.emissions.dQ; 
dQ=dQ(t>=tstart&t<=tstop,:);



% Konsentrasjon [ppm].
dT1=result.future.emissions.dT1;
dT1=dT1(t>=tstart&t<=tstop,:);

% Temperaturanomali.
dT=result.future.emissions.dT1;
dT=dT(t>=tstart&t<=tstop,:);

% Oppdater tidsvektoren.
t=t(t>=tstart&t<=tstop);

%--------------------------------------------------------------%
% Lag Figuren:

% Figur navn:
fh=figure('Name','3 c)','NumberTitle','off');

% Grenser:
xl=[min(t) max(t)];
yl=[0.85*min(min(dQ)) 1.5*max(max(dQ))];

subplot(1,2,1);
% Farger: 
c=flipud(0.85.*colormap(hsv(3)));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');


% Plott:
l1=plot(t,dQ,'LineWidth',2);    % Linje plott. 
hold on;
l2=plot(t(t<=2010),dQ(t<=2010,1),'-k','LineWidth',2);
grid minor; box on; set(gca,'TickDir','out'); axis('square'); % Kosmetikk.
xlim(xl);   
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Radiative Forcing, $\Delta Q$  [Wm$^{-2}$]',...
    'FontSize',10,'Interpreter','Latex');
legend([l1;l2],name,'Location','NorthWest','FontSize',8,...
    'Interpreter','Latex');
title('CO$_2$ Induced Forcing','FontSize',12,'Interpreter','Latex');

subplot(1,2,2);
c=flipud(0.85.*colormap(hsv(3)));
set(gca, 'ColorOrder', c, 'NextPlot', 'replacechildren');

% Plott:
l1=plot(t,dT1,'LineWidth',2);    % Linje plott. 
hold on;
l2=plot(t(t<=2010),dT1(t<=2010,1),'k','LineWidth',2);
grid minor; box on; set(gca,'TickDir','out'); axis('square'); % Kosmetikk.
xlim(xl); 
yl=[0.85*min(min(dT1)) 1.15*max(max(dT1))];
ylim(yl);
xlabel('Year','FontSize',14,'Interpreter','Latex');
ylabel('Temperature Anomaly, $\Delta T_1$  [$^\circ$C]',...
    'FontSize',10,'Interpreter','Latex');
title('Response','FontSize',12,'Interpreter','Latex');


print(fh,'-dpdf','3c','-opengl','-r300'); 






% dT2=result.historical.erf.dT2;
% dT1=result.historical.erf.dT1;
% dT2=dT2(:,:,1);
% dT1=dT1(:,1);
% imagesc(result.future.rcp.t,result.parameters.z,...
%     [dT2]')
% caxis([-1.2 1.2]);
% colorbar;
% axis ij
% colormap jet



