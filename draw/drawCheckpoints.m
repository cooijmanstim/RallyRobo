function [  ] = drawCheckpoints(checkpoints,n)
hold on;

for i = 1: size(checkpoints,1)
    y = checkpoints(i,1);
    x = checkpoints(i,2);
   text(x+0.375,y+0.5,num2str(i),'FontSize',getFontSize(n));
end
  
   
end