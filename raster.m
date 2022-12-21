clear;
data=load('preprocessing.mat').DATA;
tiledlayout(1,1);
for i=1:1
    nexttile;
    spy(data(i).S)
    daspect([8,1,1]);
    set(gca, 'YDir','normal')
    title(i-1);
end