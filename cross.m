%% Training and Testing Only

clear

load('DATA_reservoir.mat') %% has data for all the samples

% Perform TT on specific subset

[~,index] = sort([DATA.spk]);
DATA = DATA(index);
gs = ["f1","f4","f6","f8","m1","m2","m5","m8"]; % mention specific pitch for training
pick = zeros(1,2);
while diff(pick)==0
    pick = randi(8,1,2);
end
sset = gs(pick);
subset_indices = ismember([DATA.spk], sset);
DATA = DATA(subset_indices);

Nres = 250;
Nout = length(sset);

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

rZ=[];Ro=[];
for sample_i=1:numel(DATA)
    rZ(:,sample_i)=sum(DATA(sample_i).RES,2);
    index_here = find(DATA(sample_i).info == sset);
    Ro(index_here,sample_i)=1;
end

avg_spikes_digit = mean(sum(rZ,1));

Nfold = 2;
Nstride = numel(DATA)/Nfold;
Wlim = 8;

RESULT = struct([]);

for kfold = 1:Nfold

    testOn = (kfold-1)*Nstride+(1:Nstride);
    trainOn  = setdiff(1:numel(DATA),testOn);
    
    ZT=rZ(:,trainOn)';RoT=Ro(:,trainOn)';
    W0=[];  
    for i =1:Nout
        W0(:,i)=lsqlin(ZT,1000*RoT(:,i),[],[],[],[],-Wlim*ones(Nres,1),Wlim*ones(Nres,1));
    end
    W=W0';
    
%     Mn = sparse(1:length(trainOn),1+[DATA(trainOn).type],1,length(trainOn),Nout); % confusion matrix finder;
    Mn = RoT;
%     MTest = sparse(1:length(testOn),1+[DATA(testOn).type],1,length(testOn),Nout); % confusion matrix finder;
    MTest = Ro(:,testOn)';
    %---------------
    
    spikeSampleCountTest=zeros(Nout,numel(DATA));
    
    parfor insample = 1:numel(DATA)

        n_samples = length(DATA(insample).RES);
        in_spikes = DATA(insample).RES;

        V = zeros(Nout,1);
        Ibuffer = zeros(Nres,length(Iwave));
        out_spikes = zeros(Nout,1);
        Itotal = zeros(Nres,1);
        RP = zeros(Nout,1);
        Iin = zeros(Nout,1);
        
        Iin_all = zeros(Nout,n_samples);
        Itotal_all = zeros(Nres,n_samples);
        out_spikes_all = zeros(Nout,n_samples);

        for i = 1:n_samples
            Iin = W*Itotal;
            
            Iin_all(:,i) = W*Itotal;
            Itotal_all(:,i) = Itotal;
            out_spikes_all(:,i) = out_spikes;

            Ibuffer = circshift(Ibuffer,-1,2);
            Ibuffer(:,end) = 0;
            Ibuffer = Ibuffer + in_spikes(:,i)*Iwave;
            Itotal = Ibuffer(:,1);

            RP = RP-1; RP(RP<0) = 0;
            V = V*(1-dt/tau) + dt*Iin;
            V(RP>0) = 0;
            out_spikes = V>Vth; V(V<0) = Vrst; V(out_spikes) = Vrst; RP(out_spikes) = RPS;
            
        end  
        spikeSampleCountTest(:,insample) = sum(out_spikes_all,2);
    end
    
    traincounts = spikeSampleCountTest(:,trainOn);
    testcounts = spikeSampleCountTest(:,testOn);
    
    spikeSampleCountTest = [traincounts, testcounts];
    
    [M,recognized] = max(spikeSampleCountTest);
    Y = spikeSampleCountTest./repmat(M,Nout,1);
    
    M  = blkdiag(Mn,MTest);
    Y = Y./repmat(max(Y),Nout,1); Y(Y~=1)=0;
    
    misClassifiedSamples = find(sum(Y,1)~=1);
    Y(:,misClassifiedSamples) = 0;
    CM = (Y*M); % confusion matrix
    
    accuracyTrain = 100*trace(CM(:,1:Nout))/length(trainOn);
    numCorrectTrain = trace(CM(:,1:Nout));
    accuracyTest = 100*trace(CM(:,Nout+(1:Nout)))/length(testOn);
    numCorrectTest = trace(CM(:,Nout+(1:Nout)));
    
    RESULT(kfold).accTest = accuracyTest;
    RESULT(kfold).accTrain = accuracyTrain;
    RESULT(kfold).numCorrectTrain = numCorrectTrain;
    RESULT(kfold).numCorrectTest = numCorrectTest;
    
    s=sprintf('\r\n Accuracy : kFold(%i) Test %2.2f (%i/%i) Train:%2.2f (%i/%i) \n',kfold,RESULT(kfold).accTest,RESULT(kfold).numCorrectTest,length(testOn),RESULT(kfold).accTrain,RESULT(kfold).numCorrectTrain,length(trainOn));
    fprintf(s);
end

disp([RESULT.accTest])
fprintf('\r Test:')
disp(flip(sset))