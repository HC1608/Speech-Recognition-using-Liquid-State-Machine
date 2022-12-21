addpath support_functions

%% Input unit connections

rng(5);
Nin = 77;           % input neurons
Nres = 250;          % reservoir neurons
fout = 4;           % Fanout of each input neuron
fout_neg_frac = 0.5;% Fraction of negative connections in fanout

Gin = zeros(Nres,Nin);
for i = 1:Nin
    indices = randperm(Nres,fout);
    Gin(indices,i) = [-1*ones(nearest(fout*fout_neg_frac),1);...
        ones(nearest(fout*(1-fout_neg_frac)),1)];
end

%% Reservoir unit connections

resSize = [10,5,5];
Wres = [3,6;-2,-2];
r0 = 2;
Kres = [0.45 0.3;0.6 0.15];
f_inhibit = 0.2;

[X,Xn,~,G,R,E] = createNetworkM(resSize,Wres,r0,Kres,f_inhibit,1E-3);
Gres = sparse(X,Xn,G,Nres,Nres);

%% Save output

save('connections.mat','Gin','Gres')