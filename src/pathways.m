clear all; close all; clc;
% Script to read in and structure the four
% representative concentration pathways (RCPs)
% and compute the anthropogenic forcing
% post 2005.

% Based on the formula

% dQ=a*ln(C(t)/C_0);

% Where C is the CO2 equivalent concentration
% and C_0 is 278 ppm.

C_0=278;
a=3.71/log(2); 

nfiles=4; % number of files/scenarios.
% Files.
rcpfile{1,1}='../input/RCP3PD_MIDYR_CONC.DAT'; 
rcpfile{2,1}='../input/RCP45_MIDYR_CONC.DAT';
rcpfile{3,1}='../input/RCP6_MIDYR_CONC.DAT';
rcpfile{4,1}='../input/RCP85_MIDYR_CONC.DAT';
ystart=2005; % Starting year.
nrows=2501-2005; % Forcing period of interest.
ncols=2;
aconc=cell(nrows,ncols,nfiles);
for f=1:nfiles % file loop
    fid=fopen(rcpfile{f,1});
    rr=1; % Start an internal row counter.
    for i=1:10*nrows % Leave enough lines to exclude the header.
        inline=fgetl(fid);
         % Read each line as a string.
        if numel(inline)>1
            inline=strsplit(inline, ' ');
            len=size(inline,2);
            if len>=2 && isnan(str2double(inline(1,1)))...
                    && str2double(inline(1,2))>=ystart
                aconc(rr,1:ncols,f)=inline(1,2:ncols+1);
                rr=rr+1;
            end
        end
    end
end
aconc=str2double(aconc); % Convert to double.

% Load in the time step.
load('p.mat');
dt=p.dt;
clear p
npy=1/dt; % time steps per year.
conc=zeros(npy*(nrows),nfiles); % Synchronized conc. array.
t=zeros(npy*(nrows),1);
% Interpolate the concentration within each year.
for n=1:nrows % standard linear interpolation
    for i=1:npy % y=y0+(y1-y0)(x-x0)/(x1-x0)
        if n==nrows
            conc((n-1)*npy+i,:)=aconc(n-1,2,:)+...
                (aconc(n,2,:)-aconc(n-1,2,:))*((npy+i-1)*dt);
            t((n-1)*npy+i,1)=aconc(n,1,1)+(i-1)*dt;
        else
            conc((n-1)*npy+i,:)=aconc(n,2,:)+...
                (aconc(n+1,2,:)-aconc(n,2,:))*((i-1)*dt); % C(t).
            t((n-1)*npy+i,1)=aconc(n,1,1)+(i-1)*dt; % Time.  
        end
    end
end

% Compute the forcing.
dQ=a.*log(conc(:,:)./C_0);

% Ensure the forcing at year 2100 is correct (2.6,4.5 etc...),
% otherwise tune the 'a' constant to the correct value.
y=find(t==2100);
a1=2.6.*(dQ(y,1).^(-1));
a2=4.5.*(dQ(y,2).^(-1));
a3=6.0.*(dQ(y,3).^(-1));
a4=8.5.*(dQ(y,4).^(-1));
a=[a1 a2 a3 a4]';
dQ=dQ*diag(a);



% Construct a cell array of strings with the 
% associated scenario names.
name={'RCP2.6', 'RCP4.5', 'RCP6.0', 'RCP8.5'}';

% Make a structure with the rcp scenarios
rcp.dQ=dQ;
rcp.name=name';
rcp.t=t;

% Save the structure in the object file
save('r.mat', 'rcp');




