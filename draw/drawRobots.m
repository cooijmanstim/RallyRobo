function [  ] = drawRobots(robots)
colors = {'black','blue','red','green'};
hold on;
resize = 0.2;
for i = 1:  size(robots.direction,1)
    x = robots.position(i,1);
    y = robots.position(i,2);
    file = strcat('images/',colors{i},'.png');
    image = imread(file);
    rotated = imrotate(image,radtodeg(direction_get_angle(robots.direction(i, :))));
    imagesc([x+resize,x+1-resize],[y+resize,y+1-resize],rotated);
end
  
   
end

