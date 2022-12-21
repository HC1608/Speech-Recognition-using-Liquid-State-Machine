addpath AuditoryToolbox
addpath support_functions

% Parameters
DATASET = 'TI-dataset.mat';
fs = 12E3; out_fs = 1E3; df =12; 
earQ = 8; stepfactor =0.25; differ=1; 
agcf=1; tauf=32; max_AGC = 4e-4; 
BSAtau1 =4e-3; BSAtau2 = 1e-3; BSAfilterFac = 1;
rng(1);
% ----------

dataset=load(DATASET);
unprocessed = dataset.DATA;

DATA = struct([]); % output structure

parfor i = 1:numel(unprocessed) % Use parfor for parallel pool
    disp(i)
    s = LyonPassiveEar(unprocessed(i).sig,fs,df,earQ,stepfactor,differ,agcf,tauf);
    s = min(s,max_AGC);
    s = s/max_AGC;
    S = BSA(s,BSAfilterFac*BSA_filter(out_fs,BSAtau1,BSAtau2));

    DATA(i).type = unprocessed(i).class;
    DATA(i).spk = string(unprocessed(i).info);
    DATA(i).S =sparse(logical(S));
    DATA(i).info = unprocessed(i).info;
end

save('preprocessing.mat', 'DATA')