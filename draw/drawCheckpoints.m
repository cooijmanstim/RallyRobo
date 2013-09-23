function [  ] = drawCheckpoints(checkpoints)
hold on;
for i = 1: size(checkpoints,1)
    x = checkpoints(i,1);
    y = checkpoints(i,2);
   text(x+0.4,y+0.5,num2str(i),'FontSize',10);
end
  
   
end