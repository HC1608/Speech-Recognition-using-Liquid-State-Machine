%% Reservoir Response Only

clear

% Input spike trains
load preprocessing.mat;

% Network
load('connections.mat');
Nin = size(Gin,2);
Nres = size(Gin,1);

% Paramters
dt = 1e-3;

% Neuron model
Vth = 20;
tau = 64e-3;
Vrst = 0;
RefPer = 2e-3;
RPS = ceil(RefPer/dt);

% Synapse model 2nd order
tau1 = 8e-3;
tau2 = tau1/2;
I0 = 1/(tau1-tau2);
ds = 1e-3;
DS = ceil(ds/dt);
ts = 0:dt:ds+6*(tau1+tau2);
Iwave = I0*(exp(-(ts-ds)/tau1)-exp(-(ts-ds)/tau2));
Iwave(1:ceil(ds/dt)) = 0;

%% Reservoir

alpha_Gin = 8;
alpha_Gres = 1;
    
Gnet = [alpha_Gin*Gin, alpha_Gres*Gres'];
% Gnet = alpha_G*[Gin, Gres'];

DATA(1).RES = [];

parfor insample = 1:numel(DATA)
    n_samples = length(DATA(insample).S);
    in_spikes = DATA(insample).S;
    
    V = zeros(Nres,1);
    Ibuffer = zeros(Nin+Nres,length(Iwave));
    res_spikes = zeros(Nres,1);
    inres_spikes = zeros(Nin+Nres,1);
    Itotal = zeros(Nin+Nres,1);
    RP = zeros(Nres,1);
    Iin = zeros(Nres,1);
    
    Iin_all = zeros(Nres,n_samples);
    res_spikes_all = zeros(Nres,n_samples);
    Itotal_all = zeros(Nin+Nres,n_samples);
    
    for i = 1:n_samples
        inres_spikes = [in_spikes(:,i);res_spikes];
        Iin = Gnet*Itotal;
        
        res_spikes_all(:,i) = res_spikes;
        Itotal_all(:,i) = Itotal;
        Iin_all(:,i) = Iin;
        
        Ibuffer = circshift(Ibuffer,-1,2);
        Ibuffer(:,end) = 0;
        Ibuffer = Ibuffer + inres_spikes*Iwave;
        Itotal = Ibuffer(:,1);
        
        RP = RP-1; RP(RP<0) = 0;
        V = V*(1-dt/tau) + dt*Iin;
        V(RP>0) = 0;
        res_spikes = V>Vth; V(V<0) = Vrst; V(res_spikes) = Vrst; RP(res_spikes) = RPS;
    end  
    DATA(insample).RES = res_spikes_all;
end

% [a,b] = find(DATA(1).RES);
% figure(2);plot(b*dt,a,'.')
% ylim([1-Nres/100,Nres+Nres/100])
% [a,b] = find(DATA(1).S);
% figure(1);plot(b*dt,a,'.')
% ylim([1-Nin/100,Nin+Nin/100])

save('Data_reservoir.mat', 'DATA')