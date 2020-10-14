%% Runs historical and future scenarios through the simple climate model.

clear all; close all; clc;
%%%%%%%%%%%%%%%% Parameter extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('p.mat');
dt=p.dt; dz=p.dz; z=p.z; s2y=p.s2y;
al=p.alpha; C=p.C; K=p.K; K_H=p.K_H; 


%%%%%%%%%%%% 1. Historical Forcing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V=p.V; % Variation matrix for historical scenarios.
ns=size(V,1); % Number of historical scenarios.

load('h.mat');

%%%%%%%%%%%% Resolution, Forcing Allocation 

% Resolution
t=erf.t;

% Create the forcing scenarios;
nf=size(erf.component.dQ,2); % Number of forcing components.
dQc=erf.component.dQ; % Foring by component matrix.
names=erf.component.name;
% Forcing scenario matrix (converted to per year).    
dQ=(dQc*(V')).*s2y;

%%%%%%%%%%%% Compute the transient response 

% Run the historical forcing through the model.
[dT1, dT2]=scm(p,dQ,0);

% Add the results to a historical structure.
historical.erf=erf;
historical.erf.dQ=dQ./s2y; % In Wm^{-2}.
historical.erf.dT1=dT1;
historical.erf.dT2=dT2;
active=cell(nf,ns);
% Make a cell array containing the active forcings for
% each scenario.
for i=1:ns
    for j=1:nf
        if any(V(i,j))==1
            active(j,i)=names(1,j);
        end
    end
end
historical.erf.active=active;



% Add the GISS anomalies for comparisson.
load('g.mat');
historical.gistemp=gistemp;


% Delete the obsolete structures.
delete('g.mat');
delete('h.mat');

%%
%%%%%%%%%%%% 2. RCPs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load('r.mat');



%%%%%%%% Resolution, Allocation and Initialization 
% Resolution
t=rcp.t;
ns=size(rcp.dQ,2); % Number of RCP scenarios.


% Extract the forcing scenarios from the structure.
dQ=rcp.dQ;


% Combine the rcp forcings with the historical
% forcing from 1750 to 2005.
tstart=t(1,1);
start=find(historical.erf.t==tstart);
hdQ=historical.erf.dQ(1:start-1,1);
th=historical.erf.t(1:start-1,1);
hdQ=hdQ*ones(1,ns);
dQ=s2y.*[hdQ; dQ];
t=[th; t];


%%%%%%%%% Transient response.

% Run the rcp forcing through the model.
[dT1, dT2]=scm(p,dQ,0);


% Add the results to a structure.
future.rcp=rcp;
future.rcp.dQ=dQ./s2y;
future.rcp.dT1=dT1;
future.rcp.dT2=dT2;
future.rcp.t=t;

% Delete the obsolete structure
delete('r.mat');

    
%%%%%%%%%% 3. Carbon emissions scenarios %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load('e.mat');

%%%%%%%% Resolution, Allocation and Initialization %%%%%%
% Resolution
t=emissions.t;
nn=size(t,1);
kk=size(z,1);
ns=size(emissions.dQ,2); % Number of RCP scenarios.


% Extract the forcing scenarios from the structure.
dQ=emissions.dQ;
dQ=s2y.*dQ;

%%%%%%%%% Transient response.

% Run the rcp forcing through the model.
[dT1, dT2]=scm(p,dQ,0);

% Add the results to a structure.
future.emissions=emissions;
future.emissions.dT1=dT1;
future.emissions.dT2=dT2;


% Delete the obsolete structures.
delete('e.mat');
scenario=cell(1,ns);
sc=future.emissions.scenario;

%%% Make the scenario field more intuitive.
for i=1:ns
    if isnan(sc(1,i)) && isnan(sc(2,i));
        scenario{1,i}='Extrapolated decadal trend';
    elseif isnan(sc(1,i))
        scenario{1,i}=sprintf('Linear trend to zero emissions by %d',...
        sc(2,i));
    elseif isnan(sc(2,i))
        scenario{1,i}=sprintf('Factor %d of 2010 emissions in 2050 then constant.',...
        sc(1,i));
    else
        scenario{1,i}=sprintf('Factor %d of 2010 emissions in 2050 and zero by %d',...
        sc(1,i), sc(2,i));
    end
end
future.emissions.scenario=scenario;


%%%%%%%%%%%%% Compress and Save Solutions %%%%%%%%%%%%%%%%%%%%
annual;
close all; clear all; clc;
