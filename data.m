path='D:\EE746\Project LSM\ti20\train\';
gs=["m1","m2","m5","m8","f1","f4","f6","f8"];
DATA=struct([]);
for g=1:length(gs)
    cd(path+gs(g))
    for i=0:9
        for j=0:9
            temp=importdata('0'+string(j)+gs(g)+'set'+string(i)+'.sph');
            DATA(j+1,g,i+1).sig=temp.data;
            DATA(j+1,g,i+1).class=j;
            DATA(j+1,g,i+1).fs=temp.fs;
            DATA(j+1,g,i+1).info=char(gs(g));
        end
    end
end
cd('D:\EE746\Project LSM\Testing')
save('TI-dataset.mat','DATA')