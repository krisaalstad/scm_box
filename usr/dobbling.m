%% Del 4. Likevekt klimasensitivitet Oblig1 GEF1100.
close all; clear all; clc;
addpath('../src');


%% 4 a) Likevektseksperimentet:

% Laster opp parametere:
params;
z=p.z;                  % Dybdevektor.
dt=p.dt;                % Tidssteg.
nyears=1e3;             % Lengde på likevektseksperimentet [år].
npy=1/dt;               % Punkter per år.
t=(0:dt:nyears)';       % Tidsvektor.

% Regner så ut pådrivet som tilsvarer en dobbling av CO_2 konsentrasjon
% fra pre-industriellt nivå.
A=5.35;                     % [Wm^{-2}]
C0=278;                     % Pre-industriell CO_2 konsentrasjon [ppm].
C=2*C0;                     % Dobblet konsentrasjon.
dQ=A*log(C/C0);             % Tilsvarende pådriv [Wm^{-2}].
dQ=dQ.*ones(size(t)).*p.s2y;  % Pådrivsvektor med enheter Jm^{-2} per år.

% Kaller på modellen [scm.m], starter fra likevekt [\Delta T=0].
[ dT1 , dT2 ] = scm ( p , dQ , 0 );

% Forkorter tidsvektoren og temperatur anomali arrayen ved å 
% bare inkludere hvert tiende år.
t=t(1:10*npy:end);
dT2=dT2(1:10*npy:end,:);
dT1=dT1(1:10*npy:end,:);

z=[-p.h; z];                % Dybde vektor som inkluderer blandingslaget.
dT=[dT1(:,:)  dT2(:,:)];    % Temperaturanomali profil for hele søylen.

% Figur:
close all;

% Figur navn:
fh=figure('Name','4 a)','NumberTitle','off');

 
colormap jet;
imagesc(t,z,dT');
axis ij;
xlabel('Time since CO$_2$ doubling [years]','FontSize',14,'Interpreter','Latex');
ylabel('Depth, z [m]','FontSize',14,'Interpreter','Latex');
c=colorbar('SouthOutside');
xlabel(c,'$\Delta T$ [$^\circ$C]','Interpreter','Latex',...
    'FontSize',14);
hold on;
contour(t,z,dT',6,'LineWidth',2,'Color',[1 1 1]);
xlim([min(t) max(t)]);
ylim([min(z) max(z)]);
box on;  set(gca,'TickDir','out');
set(gcf,'renderer','painters')
print(fh,'-dpdf','4a','-opengl','-r300'); 


%% Figur som kan være til hjelp i oppgave 4 b) og c).

dTk=dT(t==1000,:); % Temperaturanomali profilet etter 1000 år.

% Figur navn:
fh=figure('Name','4 b) & c)','NumberTitle','off');

plot(dTk,z,'-b','LineWidth',2);
xlabel('Temperature anomaly, $\Delta T$ [$^\circ$C]',...
    'FontSize',14,'Interpreter','Latex');
ylabel('Depth, z [m]','FontSize',14,'Interpreter','Latex');
title('1000 years since CO$_2$ doubling',...
    'FontSize',14,'Interpreter','Latex');
xlim([min(dTk) max(dTk)]);
ylim([min(z) max(z)]);
grid minor; box on; axis('square'); set(gca,'TickDir','out'); % Kosmetikk.
set(gca,'YDir','Reverse');
box on;  set(gca,'TickDir','out');
set(gcf,'renderer','painters')
print(fh,'-dpdf','4b&c','-opengl','-r300'); 






