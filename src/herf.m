clear all; close all; clc;
% Script to read in and structure the forcings from
% table 1.2 in Annex 2 of WG1-AR5.

fid=fopen('../input/historical.txt'); % Open the file..
nrows=2012-1750; % Number of years of data (in file header).
ncols=12; % Number of columns (in file header).
avals=cell(nrows,ncols); % Make a cell array.
rr=1; % Start an internal row counter.
for i=1:2*nrows % Leave enough lines to exclude the header.
    inline=fgetl(fid); % Read each line as a string.
    if numel(inline)==0 || inline(1)=='!' % Skip commented and empty lines.
        continue;
    else % Otherwise add the contents to the cell array.
        inline=strsplit(inline,' '); 
        avals(rr,1:ncols)=inline(1,1:ncols);
        rr=rr+1;
        if rr>=nrows+1 % Break out of the loop as soon as nrow lines are
            break % added.
        end
    end
end
% Convert avals from a cell array of strings to an array of doubles.
avals=str2double(avals);


% Taking into account the fact that the model runs dt= X yr so there
% are X values per year, we need to expand the cell using a simple
% linear interpolation to synchroinze the forcing with the model
% and avoid discontinuities in the forcing trend.

        
load('p.mat');
dt=p.dt;
clear p;
npy=1/dt; % Time steps per year.
temp=zeros(nrows,ncols-1,npy); % Temporary array
vals=zeros(npy*(nrows),ncols-1);
for n=1:nrows % standard linear interpolation
    for k=1:ncols-1
        for i=1:npy 
            if n==nrows % Extrapolate the trend for the last year.
                temp(n,k,i)=avals(n-1,k+1)...
                    +(avals(n,k+1)...
                    -avals(n,k+1))*((npy+i-1)*dt);
            else
                temp(n,k,i)=avals(n,k+1)...
                    +(avals(n+1,k+1)...
                    -avals(n,k+1))*((i-1)*dt);
            end
            vals((n-1)*npy+i,k)=temp(n,k,i);
        end
    end
end



t=(1750:dt:(dt*(size(vals,1)-1)+1750))';
component={'CO$_2$', 'Other WMGHGs',...
    'Tropospheric O$_3$', 'Stratospheric O$_3$',...
    'Aerosols', 'Land Use Change',...
    'Stratospheric H$_2$O', 'Black Carbon',...
    'Contrails', 'Solar', 'Volcanoes'}';
erf.component.dQ=vals;
erf.component.name=component';
erf.t=t;



% Make a structure containing the historical forcing.
save('h.mat','erf');


