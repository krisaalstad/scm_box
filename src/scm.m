function [ dT1,dT2 ] = scm( p,dQ,dT_0 )
% A box-diffusion climate model scheme based on 
% Wigley & Schlesinger (Nature, 1985). By
% Kristoffer Aalstad July 2014.

% The scheme solves two coupled
% differential equations, and yields
% the transient temperature anomaly in the OML and the
% thermocline and deep ocean below.

% Requires a set of parameters defined in a
% structure p and a specified forcing dQ, and
% the initial condition dT_0.

% An oceanic column is defined such that the first vertical
% level represents temperature anomaly of a well mixed layer (the OML), 
% and remaining levels descend into the stratified thermocline and
% the deep ocean below.

% The initial condition is the initial temperature
% anomaly in the entire column. If this is set to zero
% then the model assumes an initial equilibrium
% and starts before the industrial era.



% First extract the parameters.
dt=p.dt; dz=p.dz; z=p.z;
al=p.alpha; C=p.C; K=p.K; K_H=p.K_H;

% Declare the integration length, and 
% the number of scenarios as the dimensions
% of the forcing array.
nn=size(dQ,1);
ns=size(dQ,2);

% Declare the number of depth levels
% as specified by the depth vector.
kk=size(z,1);

% Define a set of Euler levels to damp
% the computational mode.
Eul=(1:77:nn)';

% Allocate the temperature anomaly arrays.
dT1=zeros(nn,ns);
dT2=zeros(nn,kk,ns);


% Apply the initial condition.
if  numel(dT_0)==numel(z) && ...
    size(dT_0,1)==size(z,1)
    dT1(1,:)=dT_0(1,1); 
    dT2(1,:,:)=dT_0; 
elseif numel(dT_0)==1 
    dT1(1,:)=dT_0;
    dT2(1,:,:)=dT_0; 
else
    error('Error: dT_0 must be a %d by %d array or a scalar',...
        size(z,1),size(z,2));
end


% Start the numerical integration.
for n=1:nn-1 % Temporal loop.
    for s=1:ns % Scenario loop.
    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% OML temperature anomaly %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % For the initial time step and Euler
        % levels time steps use the Euler forwards
        % scheme.
        if any(n==Eul(:,1))
            dT1(n+1,s)=dT1(n,s)+...
                dt*dQ(n,s)/C-dt*al*dT1(n,s)/C...
                +dt*K_H*(dT2(n,2,s)-dT2(n,1,s))/(2*dz)/C;
        
        % For remaining time steps use a centred scheme.
        else 
            dT1(n+1,s)=dT1(n-1,s)+...
                2*dt*dQ(n,s)/C-2*dt*al*dT1(n,s)/C...
                +2*dt*K_H*(dT2(n,2,s)-dT2(n,1,s))/dz/C;
        end
                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Thermocline temperature anomaly %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Use a standard FTCS scheme to ensure numerical stability.
        % Note for diffusion the stability condition on the
        % time step is:
        % dt<=dz^2/2*kappa
        for k=2:kk-1
            dT2(n+1,k,s)=dT2(n,k,s)+...
                dt*K*(dT2(n,k+1,s)-2*dT2(n,k,s)+...
                dT2(n,k-1,s))./(dz^2);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Apply the boundary conditions %%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Continuous temperature at the base of the
        % OML.
        dT2(n+1,1,s)=dT1(n+1,s);
        
        % Zero anomaly condition (no slip) at great depth.
        dT2(n+1,end,s)=0;
        
        % Zero anomaly gradient condition (free slip) at great depth.
        %dT2(n+1,end,s)=dT2(n+1,end-1,s);
        
    end
end

