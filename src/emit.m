close all; clear all; clc;
% Script to read in and structure the historical
% Carbon emissions and construct future scenarios.

% Based on the permise that in 1750 C(CO_2) was in
% equilibrium the radiative forcing contribution
% of carbon dioxide can be approximated 
% by

% dQ=a*ln(C(t)/C_0)

% With C_0 being the 278 ppm preindustrial equilibrium concentration.
C0=278;


% The global anthropogenic emissions are taken from CDIAC 
% (Carbon Dioxide Information Analysis Center)
% see url: cdiac.esd.ornl.gov.

fid=fopen('../input/emissions.txt'); % Data file.
nrows=2011-1751; % Number of years of data.
ncols=2; % Columns of interest.
vals=cell(nrows,ncols);
rr=1; % Start an internal row counter.
for i=1:2*nrows % Leave enough lines to exclude the header.
    inline=fgetl(fid); % Read each line as a string.
    if numel(inline)==0
        continue;
    elseif inline(1)=='1' || inline(1)=='2' % Millenia
        inline=strsplit(inline,' ');
        vals(rr,1:ncols)=inline(1,1:ncols);
        rr=rr+1;
        if rr>nrows+1 % Break out of loop as soon as nrows of
            break % data are read in.
        end
    end
end
fclose(fid);

% Convert avals from a cell array of strings to an array of doubles.
vals=str2double(vals);
% Extract a year array and an emissions per year array.
yrs=vals(:,1);
aems(:,1)=vals(:,2);

% Assume zero emissions in 1750.
aems=[0;aems]; yrs=[1750;yrs];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Future emission scenarios. 

% These are specified in the parameters file by the matrix
% T.

load('p.mat');
T=p.T;
ttar=2050; % Target year with target emissions in first column of Targets.

tfend=2500; % Run until year 2500;
ny=2501-2010; % Number of years.
ns=size(T,1); % Number of scenarios.
fyrs=(2010:1:2500)'; % Time vector.
faems=zeros(ny,ns); % Future emissions array.
E0=aems(end,:); % Emissions in 2010.
faems(1,:)=E0; % Initialize with the last year of emissions data.

% Calculate the trend during the last decade.
hb=find(yrs==2010); lb=find(yrs==2000);
g10=(aems(hb)-aems(lb))./(2010-2000);

% Create the emissions scenarios as dictated by Targets.
for n=1:ny
    for s=1:ns
        if isnan(T(s,1)) && isnan(T(s,2)) % Special case (decadal trend).
            if fyrs(n,1)<=ttar
                faems(n,s)=E0+...
                    (fyrs(n,1)-fyrs(1,1))*g10;
            else
                faems(n,s)=faems(n-1,s);
            end
        elseif isnan(T(s,2)) % Level off at 2050 target emissions.
            if fyrs(n,1)<=ttar
                faems(n,s)=E0+...
                    (fyrs(n,1)-fyrs(1,1))...
                    *(T(s,1)*E0-E0)/(ttar-2010);
            else
                faems(n,s)=faems(n-1,s);
            end
        elseif isnan(T(s,1)) % Linear decline to zero at given year.
            faems(n,s)=E0+...
                (fyrs(n,1)-fyrs(1,1))...
                *(-E0)/(T(s,2)-2010);
            if faems(n,s)<0
                faems(n,s)=0;
            end
        else
            if fyrs(n,1)<=ttar % Reach target emissions.
                faems(n,s)=E0+...
                    (fyrs(n,1)-fyrs(1,1))...
                    *(T(s,1)*E0-E0)/(ttar-2010);
            else % Past target year, decline to zero emissions.
                faems(n,s)=T(s,1)*E0+...
                    (fyrs(n,1)-ttar)...
                    *(-T(s,1)*E0)/(T(s,2)-ttar);
                if faems(n,s)<0
                    faems(n,s)=0;
                end
            end
        end
    end
end               
% Combine the future and historical annual emissions into one array.
aems=aems*ones(1,ns);
aems=[aems; faems(2:end,:)];
yrs=[yrs; fyrs(2:end,1)];     

% Convert to ppm per year, 1 ppm CO_2 == 2.13x10^3 MT Carbon.
% Emissions are in MT Carbon.

cf=1/(2.13e3); % Conversion factor
aems=cf.*aems; % Annual emissions in ppm/yr.

% Employ the CO_2 response function for C(t).
% For each of the scenarios.
% P.213 IPCC WG1 AR4. Up to 2010. 

tau1=172.9; % Slow response time (yrs);
tau2=18.51; % Medium response (yrs);
tau3=1.186; % Fast response (yrs);

% Coefficients.
a0=0.217; % Associated with infinite response (-).
a1=0.259; % Associated with slow response (-).
a2=0.338; % Associated with medium response (-).
a3=0.186; % Associated with fast response (-).
    

% Calculate the annual evolution of CO_2 concentration in ppm.
% (do this annualy and not per time step to economize on run time).

aC=zeros(size(aems)); % Annual CO_2 concentration.
aC(:,:)=C0; % Initialize with the assumed pre-industrial equilibrium conc.
% Concentration as the cumulative sum of decaying CO2 pulses.
for n=1:size(aems,1)
    for j=1:size(aems,1)
        if j<=n
            aC(n,:)=aC(n,:)+aems(j,:)*(...
                a0+a1*exp(-(yrs(n,1)-yrs(j,1))/tau1)...
                +a2*exp(-(yrs(n,1)-yrs(j,1))/tau2)...
                +a3*exp(-(yrs(n,1)-yrs(j,1))/tau3));
        end
    end
end

% Synchronize the concentration array with the model, using
% linear interpolation.

dt=p.dt;
npy=1/dt; % time steps per year.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean up for memory
clear faems fyrs p vals tau1 tau2 tau3 a0 a1 a2 a3 fid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ny=size(yrs,1); % number of years.
C=zeros(npy*ny,ns); % CO_2 concentration.
t=zeros(npy*ny,1);
for n=1:ny
    for i=1:npy
        if n==ny
            C((n-1)*npy+i,:)=aC(n-1,:)+...
                (aC(n,:)-aC(n-1,:))*(npy+i-1)*dt;
            t((n-1)*npy+i,1)=yrs(n,1)+(i-1)*dt;
        else
            C((n-1)*npy+i,:)=aC(n,:)+...
                (aC(n+1,:)-aC(n,:))*((i-1)*dt);
            t((n-1)*npy+i,1)=yrs(n,1)+(i-1)*dt;
        end
    end
end
            
        
        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the 'a' factor used in the IPCC historcal CO_2 forcing.

load('h.mat');
th=erf.t; 
thend=th(end,1); % End of historical CO_2 forcing.
A=find(t==thend); % Find the index corresponding to this in the C(t) series.
dQh=erf.component.dQ(:,1); % Extract the historical CO_2 forcing.
dQhend=dQh(end,1); % Forcing at t=thend.

a=dQhend/log(C(A)/C0); % Invert the F formula to find a.

% Finally use this alpha to calculate the CO_2 forcing.
dQ=a.*log(C./C0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Create a structure with the emissions scenarios.
emissions.dQ=dQ;
emissions.C=aC;
emissions.E=aems.*(1e-3/cf)*3.667; % in GTCO_2 yr^{-1}.   
emissions.Eyear=yrs;
emissions.scenario=T';
emissions.t=t;

save('e.mat', 'emissions');




