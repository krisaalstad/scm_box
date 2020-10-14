%% List of parameters used by the model.
clear all; close all; clc;

%%
%%%%%%%%%%%%%% Physical parameters. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% All units are declared in brackets next to the parameter
% according to the following abreviations.
% yr: years, s: seconds, kg: kilograms, J: Joules, K: Kelvin,
% W: Watts (Joules per second).

% Conversion factor, per second to per year.
s2y=365*24*60*60; % (s yr^{-1}).


% Density of the OML.
rho=1e3; % (k gm^{-3}).

% Specific heat capacity of the OML.
c_w=4.18e3; % (J K^{-1} kg^{-1}).

% Mean depth of the OML.
h=75; % (m).


% OML Heat capacity weight, accounting for
% land-sea heat exchange and ocean cover.
% Tends to 1 for no heat exchange and 1-f
% (where f=0.29 is the fraction of the Earth's
% surface covered by land)
% for infinitely fast heat exchange.
gamma=0.75; % (-).

% Effective heat capacity of the OML;
C=gamma*rho*c_w*h; % (J K^{-1} m^{-2}).

% Climate feedback parameter. 
alpha=1; % Default 1 Wm^{-2}K^{-1} for ranges see Table 9.5 AR5 WG1.

% Convert to the correct units.
alpha=alpha*s2y; % Jm^{-2}K^{-1}yr^{-1}.

% Thermal diffusivity of the thermocline. [range: 1-5 cm^2s^{-1}].
K=3; % Default value: 3 cm^{2}s^{-1}

% Convert to the correct units.
K=K*1e-4*s2y;           % m^2yr^{-1}.

% Exchange coefficient between the OML and the thermocline.
K_H=gamma*rho*c_w*K; % JK^{-1}m^{-1}yr^{-1}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%-------------------------------------------------------------
%%% Historical forcing variation matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Turns forcing components on/off. (0=off, 1=on).

% Forcing by column entry: 1: CO_2, 2: WMGHGs (excluding CO_2),
% 3: Tropospheric Ozone, 4: Stratospheric Ozone, 5: Aerosols, 
% 6: Land-Use Change, 7: Stratospheric water vapor, 
% 8: Black Carbon, 9: Contrails, 10: Solar, 11: Volcanic.

I=eye(11); % Identity matrix. Each row vector represents one of the forcings.

zero=zeros(1,11); % Size of row vectors in the variation matrix.

a1=zero+1; % First scenario is the observed forcing. (DONT CHANGE THIS!)



% Construct some new scenarios (as many as you want), for example: 

a2=zeros+I(1,:); % CO2.
a3=zeros+I(2,:); % WMGHGs.
a4=zeros+I(5,:); % Aerosols.
a5=zeros+I(end,:); % Volcanoes.

% Possible variation matrix . 
% Combine the row vectors representing each scenario into a matrix.
% First row MUST be the observed forcing (a1, where all forcing is on).

V=[a1;a2;a3;a4;a5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------
%%% Future emissions matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Create carbon emissions scenarios by specifying the target value
% in 2050 (as a fraction of todays emissions) and the year in which
% zero emissions is reached. 

% If the latter is not specified (NaN: not a number) then the 
% emissions are held constant after 2050. 
% Similarly if the target is not specified (NaN) a linear trend
% is followed down to the year with zero emissions.


% In the special case that both specifications are set to NaN
% a trend extrapolation scenario is followed where the trend
% of the last 10 years continues up to 2050 at which point
% the emissions are held constant.

% The two vectors must be the same length. As an example: 

target_2050=[1; NaN; NaN];
year_zero=[NaN; 2400; 2150];

% Combine the above into a target scenario matrix, where each row
% creates a simple target scenario.
T=[target_2050 year_zero];

% In the case of the example the first row would be a scenario
% with the same emissions in 2050 as in present day, and constant
% emissions after 2050. The second row is a scenario where the 
% emissions in 2050 are half that of the present day emissions, and
% then decrease linearly down to zero emissions by the year 2300.

% NB! if a 2050 target is specified then yzero must be > 2050 (or NaN).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Don't modify the following.

%%%%%%%%%%%% Model resolution. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These parameters should not be changed %

%------------------------------------------------------------
%%% Temporal %%%%%%%%%%%%%%%%%%%%%%%

% Time step
dt=0.01; % (yr).

%------------------------------------------------------------
%%% Vertical %%%%%%%%%%%%%%%%%%%%%%%

% Vertical grid spacing.
dz=30; % (m).
% Depth below the OML.
D=3000; % (m).
% Number of vertical levels.
kk=D/dz+1;
% Depth vector.
z=(0:dz:(kk-1)*dz)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%% Parameter structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Don't modify! %
% Create a structure of key parameters to feed to the source code.

p.dt=dt;
p.dz=dz; 
p.z=z;
p.alpha=alpha;
p.C=C;
p.h=h;
p.K=K;
p.K_H=K_H;
p.s2y=s2y;
p.V=V; 
p.T=T;

clearvars -except p;
save('../src/p.mat','p');


