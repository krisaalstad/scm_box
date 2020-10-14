% Array compression run internally in scenarios.m.

% Takes the output of the climate model scenarios
% and shortens respective arrays by only considering
% annual values. 

% For forcings we recover the original annual means,
% while for the anomalies these means are computed.

% Reason for compression:
% There is a constraint on the time step within the model itself,
% but the amount of points in time (order 10^4) for 750 years
% is unecessary and requires ~0.5 GB memory to store the results structure.

% As a result of the compression the result structure is only ~5 MB.

npy=1/dt; % Timesteps per year.

%%% Perform the compression field by field.

%%%%%%%%%%%%%%% Historical forcing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% ERF

erf=historical.erf;
active=erf.active;
name=erf.component.name;

nn=size(erf.t,1);
ns=size(erf.dQ,2);
dQ=zeros(nn/npy,ns);
dT1=dQ;
dT2=zeros(nn/npy,kk,ns);
t=zeros(nn/npy,1);
dQc=zeros(nn/npy,size(erf.component.dQ,2));
for i=1:nn/npy
    dQ(i,:)=erf.dQ((i-1)*npy+1,:);
    dT1(i,:)=mean(erf.dT1((i-1)*npy+1:i*npy,:),1);
    dT2(i,:,:)=mean(erf.dT2((i-1)*npy+1:i*npy,:,:),1);
    t(i,1)=erf.t((i-1)*npy+1,1);
    dQc(i,:)=erf.component.dQ((i-1)*npy+1,:);
end
clear erf;
erf.dT1=dT1; erf.dT2=dT2; erf.t=t; erf.dQ=dQ; erf.active=active;
erf.component.dQ=dQc; erf.component.name=name; 
gistemp=historical.gistemp;
clear historical;
historical.erf=erf; historical.gistemp=gistemp;

%%%%%%%%%%%%%%%%% Future forcing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% RCP

rcp=future.rcp;
nn=size(rcp.t,1);
ns=size(rcp.dQ,2);
dQ=zeros(nn/npy,ns);
dT1=dQ;
dT2=zeros(nn/npy,kk,ns);
t=zeros(nn/npy,1);
name=rcp.name;
for i=1:nn/npy
    dQ(i,:)=rcp.dQ((i-1)*npy+1,:);
    dT1(i,:)=mean(rcp.dT1((i-1)*npy+1:i*npy,:),1);
    dT2(i,:,:)=mean(rcp.dT2((i-1)*npy+1:i*npy,:,:),1);
    t(i,1)=rcp.t((i-1)*npy+1,1);
end
clear rcp;
rcp.dT1=dT1; rcp.dT2=dT2; rcp.t=t; rcp.dQ=dQ; rcp.name=name;


%%% Emissions scenarios.

emissions=future.emissions;
nn=size(emissions.t,1);
ns=size(emissions.dQ,2);
dQ=zeros(nn/npy,ns);
dT1=dQ;
dT2=zeros(nn/npy,kk,ns);
t=zeros(nn/npy,1);
scenario=emissions.scenario;
C=emissions.C;
E=emissions.E;
for i=1:nn/npy
    dQ(i,:)=emissions.dQ((i-1)*npy+1,:);
    dT1(i,:)=mean(emissions.dT1((i-1)*npy+1:i*npy,:),1);
    dT2(i,:,:)=mean(emissions.dT2((i-1)*npy+1:i*npy,:,:),1);
    t(i,1)=emissions.t((i-1)*npy+1,1);
end
clear emissions;
emissions.dT1=dT1; emissions.dT2=dT2; emissions.t=t; 
emissions.dQ=dQ; emissions.scenario=scenario;
emissions.E=E; emissions.C=C;
clear future;
future.emissions=emissions; future.rcp=rcp;


%%%%%%%%%%%%%%%% Create and save the final structure %%%%%%%%%%%%%%%%
result.future=future; result.historical=historical;
result.parameters=p;
delete('p.mat');
save('../usr/result.mat','-v7.3', 'result');




