% Kjør modellen (med riktige enheter).
run;
% Last opp strukturen.
load('result.mat');
% Definer tid og anomali arrayer fra GISS feltet.
t=result.historical.gistemp.t; dT=result.historical.gistemp.dT;
% Finn indeksen som svarer til minimum temperaturanomali.
mindT=min(dT);
minind=find(dT==mindT);
% Skriv ut det tilsvarende året til kommandovinduet.
minyear=t(minind);
fprintf(['\n Minimum temperaturanomali var dT=%.2fC'...
     ' som fant sted i året %d \n'],...
    mindT, minyear);
