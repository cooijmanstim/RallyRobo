function [  ] = drawRobots(robots)
colors = {'black','blue','red','green'};
hold on;
resize = 0.2;
for i = 1: length(robots.direction)
    x = robots.position(i,1);
    y = robots.position(i,2);
    file = strcat('images/',colors{i},'.png');
    image = imread(file);
    rotated = imrotate(image,angle(robots.direction(i, 1)+i*robots.direction(i, 2)));
    imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],rotated);
end
  
   
end

