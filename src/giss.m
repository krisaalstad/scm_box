clear all; close all; clc;
% Script to read in and structure the global land ocean
% temperature index (LOTI) from GISS spanning years 1880-2013.

% Source of data:
% (url) http://data.giss.nasa.gov/gistemp/tabledata_v3/GLB.Ts+dSST.txt


%%%%%%%%%%%%%%%%% Read the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid=fopen('../input/GISS.txt'); % Data file.
nrows=2013-1880; % Number of years of data.
ncols=2; % Columns of interest.
vals=cell(nrows,ncols);
rr=1; % Start an internal row counter.
for i=1:2*nrows % Leave enough lines to exclude the header.
    inline=fgetl(fid); % Read each line as a string.
    if numel(inline)==0
        continue;
    elseif inline(1)=='1' || inline(1)=='2' % Millenia
        inline=strsplit(inline,' ');
        vals(rr,1)=inline(1,1); % Year
        vals(rr,2)=inline(1,14);
        rr=rr+1;
        if rr>nrows+1 % Break out of loop as soon as nrows of
            break % data are read in.
        end
    end
end
vals=str2double(vals);


% Extract the year and temperature anomalies;
yrs=vals(:,1); dT=vals(:,2);


%%%%%%%%%%%%%% Process the data %%%%%%%%%%%%%%%%%%%%%%%%


% Convert units from cK to K;
dT=0.01.*dT;


% Calculate the 5 year centered running mean anomaly. 
% Requires the removal of the two first and 
% last years in the series.

mdT=zeros(size(dT,1)-4,1);
myrs=yrs(3:end-2,1);

for i=1:size(mdT,1)
    mdT(i,1)=mean(dT(i:(i+4),1));
end


%%%%%%%%%% Structure the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


gistemp.dT=mdT;
gistemp.t=myrs;

save('g.mat', 'gistemp');



